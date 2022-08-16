import "CoreLibs/graphics"

local gfx <const> = playdate.graphics

local SUM_THRESHOLD <const> = 4
local NUM_CIRCLES <const> = 5
local width <const> = playdate.display.getWidth()
local height <const> = playdate.display.getHeight()
local palette <const> = {
  {0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF},
  {0x77, 0x77, 0xDD, 0xDD, 0x77, 0x77, 0xDD, 0xDD},
  {0x77, 0x77, 0xDD, 0xDD, 0x77, 0x77, 0xDD, 0xDD},
  {0x88, 0x88, 0x22, 0x22, 0x88, 0x88, 0x22, 0x22},
  {0x88, 0x88, 0x22, 0x22, 0x88, 0x88, 0x22, 0x22},
  {0x0, 0x22, 0x0, 0x88, 0x0, 0x22, 0x0, 0x88},
  {0x0, 0x22, 0x0, 0x88, 0x0, 0x22, 0x0, 0x88},
  {0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0}
}

local circles = {};

local function init()
  playdate.display.setRefreshRate(50) -- Sets framerate to 50 fps
  math.randomseed(playdate.getSecondsSinceEpoch()) -- seed for math.random
  gfx.setFont(font) -- DEMO

  for i=1, NUM_CIRCLES, 1 do
    table.insert(circles, {
      x = math.random(width),
      y = math.random(height),
      r = math.random(80) + 40,
      vx = math.random(3)/2 - 1.5,
      vy = math.random(3)/2 - 1.5,
    });
  end
end

init()

local function updateGame()
end

local function drawGame()
  gfx.pushContext()

  --for every circle, do collision with screen edges
  for _, c in ipairs(circles) do
    c.x += c.vx;
    c.y += c.vy;
    if c.x < 0 then
      c.vx = math.abs(c.vx);
    end
      if c.x > width then
        c.vx = -math.abs(c.vx);
    end
      if c.y < 0 then
        c.vy = math.abs(c.vy);
    end
    if c.y > height then
      c.vy = -math.abs(c.vy);
    end
  end

  --only update a random sampling of the screen's pixels (procedural dithering)
  for i=0, 2500, 1 do
    local x = math.random(width)
    local y = math.random(height)
    local sum = 0
    --check if pixel is within bounding radius, and calculate distance if so
    for _, c in ipairs(circles) do
      if math.abs(x - c.x) < c.r and math.abs(y - c.y) < c.r then
        local dx = x - c.x
        local dy = y - c.y
        local d = dx*dx + dy*dy
        sum += c.r*c.r/d
      end
    end
    if sum > SUM_THRESHOLD then
      gfx.setPattern(palette[math.min(math.floor(sum/2), #palette)])
    else
      gfx.setPattern(palette[1])
    end
    gfx.fillCircleAtPoint(x, y, 2)
  end
  
  gfx.popContext()
end

function playdate.update()
  updateGame()
  drawGame()
  playdate.drawFPS(0,0) -- FPS widget
end
