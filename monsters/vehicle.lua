vehicle = {}

function vehicle.init(args)
  self.rideVehicle = false
  self.seatbelt = false
end

function vehicle.update()
  local region = entity.configParameter("metaBoundBox", nil)
  local 
  
  if self.rideVehicle then
	entity.setForceRegion(region, force)
  end
end

function isVehicle()
  return true
end

function ride()
  if self.rideVehicle then
	self.rideVehicle = false
  else
	self.rideVehicle = true
  end
end

function seatbelt()
  return self.seatbelt
end