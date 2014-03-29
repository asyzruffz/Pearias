vehicle = {}

function vehicle.init(args)
  
end

function vehicle.update()
  local region = entity.configParameter("metaBoundBox", nil)
  
  if self.rideVehicle then
	setForceRegion(region, force)
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