# frozen_string_literal: true

require 'rails_helper'

def event_attributes_for(event:, fields: event_fields)
  event.attributes
       .slice(*fields)
       .tap { _1['starts_at'] = _1['starts_at']&.iso8601 }
end

def error_name_for(missing_field:)
  missing_field.capitalize.gsub('_', ' ')
end

def event_fields
  [ 'id', 'name', 'description', 'address', 'starts_at', 'max_tickets' ]
end

def event_fields_without_id
  event_fields - %w[id]
end

def trigger_list_events_request
  get :index, params:
end

RSpec.describe EventsController do
  let(:user) { create(:user) }

  before { sign_in(user) }

  describe "#create" do
    subject(:create_event) { post(:create, params:, as: :json) }

    let!(:event) { build(:event) }

    context "when the user is not logged in" do
      let(:params) { event_attributes_for(event:) }

      before { sign_out(user) }

      it "retuns an error message telling the user to sign in" do
        create_event

        expect(response.parsed_body['error']).to eq("You need to sign in or sign up before continuing.")
      end
    end

    context "with valid parameters" do
      let(:params) { event_attributes_for(event:, fields: event_fields_without_id) }

      it "returns a successful response" do
        expect(create_event).to be_successful
      end

      it "creates a new Event" do
        expect { create_event }.to change(Event, :count).by(1)
      end

      describe "the response" do
        it "contains a valid JSON object" do
          create_event

          expect(response.body).to be_present
          expect(response.parsed_body).to be_a(Hash)
        end

        it "includes the event id" do
          create_event

          expect(response.parsed_body['id']).to be_an(Integer)
        end

        it "includes the posted data" do
          create_event

          expect(response.parsed_body.slice(*event_fields_without_id)).to eq(params)
        end

        it "excludes filtered-out fields" do
          create_event

          expect(response.parsed_body.keys).not_to include(%w[created_at updated_at])
        end
      end
    end

    context "with invalid parameters" do
      let(:params) { event_attributes_for(event:, fields:) }
      let(:fields) { event_fields_without_id }

      context "when one of the parameters is missing" do
        let(:fields) { event_fields_without_id.excluding(event_fields_without_id.sample) }

        it "does not create a new Event" do
          expect { create_event }.to change(Event, :count).by(0)
        end

        it "returns an error http response" do
          create_event

          expect(response).to have_http_status(:unprocessable_entity)
        end
      end

      event_fields_without_id.each do |missing_field|
        context "when the '#{missing_field}' are missing" do
          let(:fields) { event_fields_without_id.excluding(missing_field) }

          it "retuns a proper error message" do
            create_event

            expect(response.parsed_body['error']).to match("#{error_name_for(missing_field:)} is required")
          end
        end
      end

      context "when `name` is longer than 256 characters" do
        let(:excessively_long_name) { Faker::Lorem.words(number: 200).join(' ') }
        let!(:event) { build(:event, name: excessively_long_name) }

        it "retuns a proper error message" do
          create_event

          expect(response.parsed_body['error']).to match("Name is too long")
        end
      end

      context "when `address` is longer than 256 characters" do
        let(:excessively_long_address) { Faker::Lorem.words(number: 200).join(' ') }
        let!(:event) { build(:event, address: excessively_long_address) }

        it "retuns a proper error message" do
          create_event

          expect(response.parsed_body['error']).to match("Address is too long")
        end
      end

      context "when `max_tickets` is zero" do
        let!(:event) { build(:event, max_tickets: 0) }

        it "retuns a proper error message" do
          create_event

          expect(response.parsed_body['error']).to match("Max tickets must be greater than 0")
        end
      end

      context "when `max_tickets` is negative" do
        let!(:event) { build(:event, max_tickets: -1) }

        it "retuns a proper error message" do
          create_event

          expect(response.parsed_body['error']).to match("Max tickets must be greater than 0")
        end
      end
    end
  end

  describe "#list" do
    subject(:list_events) { trigger_list_events_request }

    let!(:events) { create_list(:event, 10) }
    let(:params) { { limit:, offset: } }
    let(:limit) { 4 }
    let(:offset) { 2 }

    context "when the user is not logged in" do
      before { sign_out(user) }

      it "retuns an error message telling the user to sign in" do
        list_events

        expect(response.body).to be_blank
        expect(response).to have_http_status(302)
      end
    end

    it "retuns an array of events" do
      list_events

      expect(response.parsed_body).to be_an(Array)
      expect(response.parsed_body).to all be_a(Hash)
      expect(response.parsed_body.map(&:keys).map(&:sort)).to all match(event_fields.sort)
    end

    it "limits the collection size to the given limit parameter" do
      list_events

      expect(response.parsed_body.size).to eq(limit)
    end

    it "applies the provided the offset" do
      list_events

      expect(response.parsed_body.map { _1['id'] }).to eq(events[offset..offset+limit-1].map(&:id))
    end

    describe "caching" do
      let(:memory_store) { ActiveSupport::Cache.lookup_store(:memory_store) }
      let(:cache) { Rails.cache }

      before do
        allow(Rails).to receive(:cache).and_return(memory_store)
        Rails.cache.clear
      end

      let(:query_for_listing_events) do
        'SELECT "events"\.\* FROM "events" ORDER BY "events"\."id" ASC LIMIT \$1 OFFSET \$2'
      end

      context "when the events are not modified between identical requests" do
        it "fetches the events once" do
          expect do
            10.times { trigger_list_events_request }
          end.to(
            equal_query_limit(1).with(/#{query_for_listing_events}/)
          )
        end
      end

      context "when an event is modified between identical requests" do
        let(:offset) { 0 }

        it "fetches the events twice" do
          expect do
            trigger_list_events_request
            Event.first.update(description: Faker::Lorem.sentence)
            10.times { trigger_list_events_request }
          end.to(
            equal_query_limit(2).with(/#{query_for_listing_events}/)
          )
        end
      end
    end
  end
end
