# frozen_string_literal: true

require 'rails_helper'

def booking_fields
  [ 'id', 'event_id', 'user_id', 'booked_tickets' ]
end

def booking_fields_for_create
  booking_fields - %w[id user_id]
end

def booking_params_for(booking:, fields: booking_fields, override: nil)
  booking.attributes
         .slice(*fields)
         .then { _1['tickets_to_book'] = _1.delete('booked_tickets') if _1['booked_tickets']; _1 }
         .merge(**override&.with_indifferent_access || {})
end

def error_name_for(missing_field:)
  field_to_param(missing_field).capitalize.gsub('_id', '').gsub('_', ' ')
end

def field_to_param(field)
  field == 'booked_tickets' ? 'tickets_to_book' : field
end

def perform_list_mine_request
  get :list_mine, params:
end

RSpec.describe BookingsController do
  let(:user) { create(:user) }

  before { sign_in(user) }

  describe "#create" do
    subject(:create_booking) { post(:create, params:, as: :json) }

    let(:event) { create(:event) }
    let(:booking) { build(:booking, event:) }

    context "when the user is not logged in" do
      let(:params) { booking_params_for(booking:, fields: booking_fields_for_create) }

      before { sign_out(user) }

      it "retuns an error message telling the user to sign in" do
        create_booking

        expect(response.parsed_body['error']).to eq("You need to sign in or sign up before continuing.")
      end
    end

    context "with valid parameters" do
      let(:params) { booking_params_for(booking:, fields: booking_fields_for_create, override:) }
      let(:override) { nil }

      it "returns a successful response" do
        expect(create_booking).to be_successful
      end

      it "creates a new Booking" do
        expect { create_booking }.to change(Booking, :count).by(1)
      end

      it "updates the number of booked tickets on the Event record" do
        expect { create_booking }.to change { event.reload.booked_tickets }.from(0).to(booking.booked_tickets)
      end

      describe "the response" do
        it "contains a valid JSON object" do
          create_booking

          expect(response.body).to be_present
          expect(response.parsed_body).to be_a(Hash)
        end

        it "includes the event id" do
          create_booking

          expect(response.parsed_body['id']).to be_an(Integer)
        end

        it "includes the posted data" do
          create_booking

          expected_fields = response.parsed_body
                                    .slice(*booking_fields_for_create)
                                    .transform_keys { field_to_param(_1) }

          expect(expected_fields).to eq(params)
        end

        it "excludes filtered-out fields" do
          create_booking

          expect(response.parsed_body.keys).not_to include(%w[created_at updated_at])
        end
      end

      context "when there are less tickets than the requested amount" do
        let(:override) { { tickets_to_book: event.max_tickets - event.booked_tickets + 1 } }

        it "retuns an error message" do
          create_booking

          expect(response.parsed_body['error']).to match("Not enough tickets available")
        end

        it "does not create a new Booking" do
          expect { create_booking }.to change(Booking, :count).by(0)
        end

        it "does not change the event" do
          expect { create_booking }.not_to change(event.reload, :booked_tickets)
        end
      end

      context "when the event does not exist" do
        let(:requested_event_id) { Event.order(id: :asc).last.id + 1 }
        let(:override) { { event_id: requested_event_id } }

        it "retuns an error message" do
          create_booking

          expect(response.parsed_body['error']).to match("Could not find event with id #{requested_event_id}")
        end

        it "does not create a new Booking" do
          expect { create_booking }.to change(Booking, :count).by(0)
        end
      end
    end

    context "with invalid parameters" do
      let(:params) { booking_params_for(booking:, fields:) }
      let(:fields) { booking_fields_for_create }

      context "when one of the parameters is missing" do
        let(:fields) { booking_fields_for_create.excluding(booking_fields_for_create.sample) }

        it "does not create a new Booking" do
          expect { create_booking }.to change(Booking, :count).by(0)
        end

        it "returns an error http response" do
          create_booking

          expect(response).to have_http_status(:unprocessable_entity)
        end
      end

      booking_fields_for_create.each do |missing_field|
        context "when the '#{missing_field}' are missing" do
          let(:fields) { booking_fields_for_create.excluding(missing_field) }

          it "retuns a proper error message" do
            create_booking

            expect(response.parsed_body['error']).to match("#{error_name_for(missing_field:)} is required")
          end
        end
      end
    end
  end

  describe "#list_mine" do
    subject(:list_mine) { perform_list_mine_request }

    let(:user_2) { create(:user) }

    let!(:event_group_1) { create_list(:event, 20) }
    let!(:event_group_2) { create_list(:event, 20) }

    let!(:bookings_user_1) do
      [
        event_group_1.sample(5).map { create(:booking, user:, event: _1) },
        event_group_2.sample(5).map { create(:booking, user:, event: _1) }
      ].flatten
    end
    let!(:bookings_user_2) do
      [
        event_group_1.sample(5).map { create(:booking, user: user_2, event: _1) },
        event_group_2.sample(5).map { create(:booking, user: user_2, event: _1) }
      ].flatten
    end

    let(:params) { { limit:, offset:, user_id: user.id } }
    let(:limit) { 4 }
    let(:offset) { 2 }

    context "when the user is not logged in" do
      before { sign_out(user) }

      it "retuns an error message telling the user to sign in" do
        list_mine

        expect(response.body).to be_blank
        expect(response).to have_http_status(302)
      end
    end

    it "retuns an array of bookings" do
      list_mine

      expect(response.parsed_body).to be_an(Array)
      expect(response.parsed_body).to all be_a(Hash)
      expect(response.parsed_body.map(&:keys).map(&:sort)).to all match(booking_fields.sort)
    end

    it "limits the collection size to the given limit parameter" do
      list_mine

      expect(response.parsed_body.size).to eq(limit)
    end

    it "applies the provided the offset" do
      list_mine

      expect(response.parsed_body.map { _1['id'] }).to eq(bookings_user_1[offset..offset+limit-1].map(&:id))
    end

    describe "caching" do
      let(:memory_store) { ActiveSupport::Cache.lookup_store(:memory_store) }
      let(:cache) { Rails.cache }

      before do
        allow(Rails).to receive(:cache).and_return(memory_store)
        Rails.cache.clear
      end

      let(:query_for_listing_user_bookings) do
        'SELECT "bookings"\.\* FROM "bookings" ' \
        'WHERE "bookings"\."user_id" = \$1 ' \
        'ORDER BY "bookings"\."id" ASC LIMIT \$2 OFFSET \$3'
      end

      context "when the bookings are not modified between identical requests" do
        it "fetches the bookings once" do
          expect do
            10.times { perform_list_mine_request }
          end.to(
            equal_query_limit(1).with(/#{query_for_listing_user_bookings}/)
          )
        end
      end

      context "when a booking is modified between identical requests" do
        let!(:event_group_3) { create_list(:event, 20) }
        let(:limit) { 20 }
        let(:offset) { 0 }

        it "fetches the bookings twice" do
          expect do
            perform_list_mine_request
            create(:booking, user:, event: event_group_3.sample)
            10.times { perform_list_mine_request }
          end.to(
            equal_query_limit(2).with(/#{query_for_listing_user_bookings}/)
          )
        end
      end
    end
  end
end
