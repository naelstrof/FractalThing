-- Copyright (c) 2017 Dalton Nell
-- 
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
-- 
-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.
-- 
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.

flux = require "flux/flux"

function love.load()
    local pixelcode = [[
        uniform float bot;
        uniform float top;
        vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords )
        {
            float ratio = love_ScreenSize.x/love_ScreenSize.y;
            float x = (texture_coords.x-0.5)*4*ratio;
            float y = (texture_coords.y-0.5)*4;
            vec2 p = vec2(x,y)/(x*x+y*y);
            float z = (x-p.x)*(x-p.x)+(y-p.y)*(y-p.y);
            float abs = length( p );
            float depth = 0;
            while( abs > bot && abs < top && depth < 10 ) {
                z = (x-p.x)*(x-p.x)+(y-p.y)*(y-p.y);
                p = vec2( (x-p.x)/z, (-y+p.y)/z );
                abs = length( p );
                depth++;
            }
            vec4 texcolor = vec4(0);
            if ( depth < 10 ) {
                texcolor = vec4(1.f - 1.f /(1.f+abs));
            }
            return texcolor * color;
        }
    ]]
    local vertexcode = [[
		vec4 position( mat4 transform_projection, vec4 vertex_position )
        {
            return transform_projection * vertex_position;
        }
    ]]
    fractalShader = love.graphics.newShader(pixelcode, vertexcode)
    love.window.setMode(500, 500, {fullscreen=false, resizable=true, vsync=false})
    canvas = love.graphics.newCanvas(500,500);
    w = love.graphics.getWidth()/2
    h = love.graphics.getHeight()/2
    bot = {}
    bot.x = 1
    top = {}
    top.x = 1
    started = false
    zoom = 1
    zoompos = {x=0,y=0}
    color = {r=1,g=1,b=1}
end

function resetbot()
    flux.to(bot, 6, {x=0}):ease("quadinout"):after(bot, 6, {x=1}):ease("quadinout"):oncomplete(resetbot)
end

function resettop()
    flux.to(top, 8, {x=10}):ease("quadinout"):after(top, 8, {x=1}):ease("quadinout"):oncomplete(resettop)
end

function resetcolor()
    flux.to(color, 3, {r=1,g=0,b=0}):ease("quadinout")
    :after(color, 3, {r=1,g=1,b=0}):ease("quadinout")
    :after(color, 3, {r=0,g=1,b=0}):ease("quadinout")
    :after(color, 3, {r=0,g=1,b=1}):ease("quadinout")
    :after(color, 3, {r=0,g=0,b=1}):ease("quadinout")
    :after(color, 3, {r=1,g=0,b=1}):ease("quadinout")
    :after(color, 3, {r=1,g=1,b=1}):ease("quadinout")
    :oncomplete(resetcolor)
end

function love.resize(width,height)
    canvas = love.graphics.newCanvas( width, height )
    w = love.graphics.getWidth()/2;
    h = love.graphics.getHeight()/2;
end

function love.keypressed(k)
    if k == 'escape' then
        love.event.quit()
    elseif k == 'up' then
        zoompos.y = zoompos.y + (1/zoom)*25
    elseif k == 'down' then
        zoompos.y = zoompos.y - (1/zoom)*25
    elseif k == 'left' then
        zoompos.x = zoompos.x + (1/zoom)*25
    elseif k == 'right' then
        zoompos.x = zoompos.x - (1/zoom)*25
    end
end

function love.wheelmoved(x, y)
    if y > 0 then
        zoom = zoom*1.04
    else
        zoom = zoom*.96
    end
end

function love.update( dt )
    if ( not started ) then
        resettop()
        resetbot()
        resetcolor()
        started = true
    end
    flux.update(dt)
end

function love.draw()
    love.graphics.setColor(255*color.r,255*color.g,255*color.b,255)
    love.graphics.setShader( fractalShader )
    love.graphics.translate( -zoompos.x+w, -zoompos.y+h )
    love.graphics.scale( zoom )
    fractalShader:send( "top", top.x )
    fractalShader:send( "bot", bot.x )
    love.graphics.draw(canvas, zoompos.x-w, zoompos.y-h)
    love.graphics.setShader()
end
