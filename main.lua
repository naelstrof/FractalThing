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
    w = love.graphics.getWidth()/2;
    h = love.graphics.getHeight()/2;
    love.window.setMode(500, 500, {fullscreen=false, resizable=true, vsync=false})
    canvas = love.graphics.newCanvas(500,500);
    bot = love.math.random()
    top = love.math.random()*10
end

function love.resize(width,height)
    canvas = love.graphics.newCanvas( width, height )
end

function love.keypressed(k)
    if k == 'escape' then
        love.event.quit()
    end
end

function love.update( dt )
    bot = bot-dt*.125
    top = top+dt*1.5
    if ( bot < 0 ) then bot = 1 end
    if ( top > 10 ) then top = 1 end
end

function love.draw()
    love.graphics.setColor(0,255,0,255)
    love.graphics.setShader( fractalShader )
    fractalShader:send( "top", top )
    fractalShader:send( "bot", bot )
    love.graphics.draw(canvas)
    love.graphics.setShader()
end
