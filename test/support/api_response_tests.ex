defmodule ApiResponseTests do
  defmacro test_all_response_types(method_name, success_data) do
    quote do
      test "it returns data when successful" do
        use_cassette "success" do
          response = GoogleGeocodingApi.unquote(method_name)("30 Rockefeller Plaza. New York, NY")
          assert response == {:ok, unquote(success_data)}
        end
      end

      test "it returns nil if no results" do
        use_cassette "zero_results" do
          response = GoogleGeocodingApi.unquote(method_name)("30 Rockefeller Plaza. New York, NY")
          assert response == {:error, "No results found for that address"}
        end
      end

      test "it fails on query limit reached" do
        use_cassette "over_query_limit" do
          response = GoogleGeocodingApi.unquote(method_name)("30 Rockefeller Plaza. New York, NY")
          assert response == {:error, "You have reached your query limit"}
        end
      end

      test "it fails on request denied" do
        use_cassette "request_denied" do
          response = GoogleGeocodingApi.unquote(method_name)("30 Rockefeller Plaza. New York, NY")
          assert response == {:error, "Your request was denied"}
        end
      end

      test "it fails on invalid request" do
        use_cassette "invalid_request" do
          response = GoogleGeocodingApi.unquote(method_name)("30 Rockefeller Plaza. New York, NY")
          assert response == {:error, "Your request was invalid"}
        end
      end

      test "it fails on unknown error" do
        use_cassette "unknown_error" do
          response = GoogleGeocodingApi.unquote(method_name)("30 Rockefeller Plaza. New York, NY")
          assert response == {:error, "Unknown error, this may succeed if you try again"}
        end
      end

      test "it appends key to URL if it exists" do
        Application.put_env(:google_geocoding_api, :api_key, "fake_key")
        use_cassette "request_denied_with_api_key", match_requests_on: [:query] do
          response = GoogleGeocodingApi.unquote(method_name)("30 Rockefeller Plaza. New York, NY")
          assert response == {:error, "Your request was denied"}
        end
      end

      test "it does not append key to URL if it does not exist" do
        use_cassette "success", match_requests_on: [:query] do
          response = GoogleGeocodingApi.unquote(method_name)("30 Rockefeller Plaza. New York, NY")
          assert response == {:ok, unquote(success_data)}
        end
      end

      test "it adds options to URL if it exists" do
        use_cassette "request_with_options", match_requests_on: [:query] do
          response = GoogleGeocodingApi.unquote(method_name)("30 Rockefeller Plaza. New York, NY", region: "XYZ")
          assert response == {:ok, unquote(success_data)}
        end
      end
    end
  end
end
