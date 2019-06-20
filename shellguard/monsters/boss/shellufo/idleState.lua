require "/scripts/vec2.lua"

idleState = {}

function idleState.enter()
  if hasTarget() then return nil end
  
  return {
    timer = 0,
    bobInterval = 4,
    bobHeight = 2,
    grounded = false,
    searchVector = {0, -128},
    spawnPoint = {0, 32},
    searchWidth = 4, --starts at 0
    searchOffsetVector = {10, 0}
  }
end

function idleState.update(dt, stateData)
  mcontroller.controlFace(1)
  stateData.timer = stateData.timer + dt
  if stateData.timer > stateData.bobInterval then
    stateData.timer = stateData.timer - stateData.bobInterval
  end
  
  if not stateData.grounded then
    local collidePoints = {}
    for i = 0, stateData.searchWidth do
      local offsetVector = vec2.mul(stateData.searchOffsetVector, math.ceil(i / 2) * ((-1) ^ i))
      local searchPos = vec2.add(mcontroller.position(), offsetVector)
      table.insert(collidePoints, world.lineCollision(searchPos, vec2.add(searchPos, stateData.searchVector)))
    end
    local collidePoint = nil
    for _, point in pairs(collidePoints) do
      if (not collidePoint) or (collidePoint[2] < point[2]) then
        collidePoint = point
      end
    end
    if collidePoint then
      stateData.grounded = true
      self.spawnPosition = vec2.add(collidePoint, stateData.spawnPoint)
      mcontroller.setPosition(vec2.add(collidePoint, stateData.spawnPoint))
    end
  end
  
  for i = 0, stateData.searchWidth do
    local offsetVector = vec2.mul(stateData.searchOffsetVector, math.ceil(i / 2) * ((-1) ^ i))
    local searchPos = vec2.add(mcontroller.position(), offsetVector)
    world.debugLine(searchPos, vec2.add(searchPos, stateData.searchVector), "cyan")
  end

  local bobOffset = math.sin((stateData.timer / stateData.bobInterval) * math.pi * 2) * stateData.bobHeight
  local targetPosition = {self.spawnPosition[1], self.spawnPosition[2] + bobOffset}
  local toTarget = world.distance(targetPosition, mcontroller.position())

  mcontroller.controlApproachVelocity(vec2.mul(toTarget, 1/dt), 30)
end
