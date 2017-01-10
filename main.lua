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
    love.window.setMode(500, 500, {fullscreen=false, resizable=true, vsync=false})
    canvas = love.graphics.newCanvas( 500, 500 )
    w = love.graphics.getWidth()/2
    h = love.graphics.getHeight()/2
    rx = 2
    ry = 2
    sx = w/rx
    sy = -h/ry
    deltax = rx/w
    deltay = ry/h
    x = -rx
    y = -ry
    bot = love.math.random()
    top = love.math.random()*10
    pause = 0
    love.graphics.translate(w,h)
    love.graphics.scale(sx,sy)
    points = {};
end

function love.resize(width, height)
    width = width + 1
    canvas = love.graphics.newCanvas( width, height )
    love.graphics.origin()
    w = width/2
    h = height/2
    sx = w/rx
    sy = -h/ry
    deltax = rx/w
    deltay = ry/h
    x = -rx
    y = -ry
    bot = love.math.random()
    top = love.math.random()*10
    pause = 0
end

function love.keypressed(k)
    if k == 'escape' then
        love.event.quit()
    end
end

function love.update( dt )
    -- induces a pause after each generation, allowing for screenshots or whatever
    --if ( pause > 0 ) then
        --pause = pause - dt
        --love.timer.sleep(0.01)
        --return
    --end
    t = love.timer.getTime()
    points = {};
    i=1
    while ( love.timer.getTime()-t < 0.01 ) do
        p = x/(x*x+y*y)
        q = y/(x*x+y*y)
        z = (x-p)*(x-p)+(y-q)*(y-q)
        abs = math.sqrt( p*p + q*q )
        depth = 0
        while( abs > bot and abs < top ) do
            depth = depth+1
            if ( depth > 10 ) then
                break
            end
            z = (x-p)*(x-p)+(y-q)*(y-q)
            p = (x-p)/z
            q = (-y+q)/z
            abs = math.sqrt( p*p + q*q )
        end
        if ( depth > 10 ) then
            c = 0
        else
            c = 1 - 1 / (1+abs);
            c = c * 255
        end
        points[i] = { x, y, 0, c, 0, 255 }
        i = i + 1
        x = x + deltax
        if ( x > rx ) then
            y = y + deltay
            x = -rx
        end
        if ( y > ry ) then
            y = -ry
            --bot = love.math.random()
            --top = love.math.random()*10
            bot = bot - 0.02
            top = top + 0.24
            if ( bot < 0 ) then
                bot = 1
            end
            if ( top > 10 ) then
                top = 1
            end
            pause = 1
            break
        end
    end
end

function love.draw()
    love.graphics.setCanvas(canvas)
    love.graphics.origin()
    love.graphics.translate(w,h)
    love.graphics.scale(sx,sy)
    love.graphics.points( points )

    love.graphics.setCanvas()
    love.graphics.origin()
    love.graphics.draw(canvas)
end
