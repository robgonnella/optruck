json.array!(@drivers) do |driver|
  json.extract! driver, :id, :first_name, :last_name, :latitude, :longitude, :address, :desired_city, :desired_state, :desired_zip, :driver_id_tag, :driver_phone, :driver_truck_type, :active, :driver_status, :driver_contract_number, :driver_availability, :driver_company, :comments, :active
  json.url driver_url(driver, format: :json)
end
