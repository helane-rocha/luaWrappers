dofile("modules.lua")
require("lagrangian")
require("win")

function vec(t) 
  local m=#t
  local a=array.double(m)
  for i=1,m do
    a:set(i-1,t[i])
  end
  return a	  
end

function symbols(a) 
  for i=1,#a do
    _G[a[i]]=ginac.symbol(a[i])
  end
end

symbols {"R","m","g","rho","drho","theta","dtheta"}

L=m/(2*R^2)*(R^2*drho^2+R^2*rho^2*dtheta^2+4*rho^2*drho^2-2*R*g*rho^2)

idyn=iteration_map(L,{rho,theta},{drho,dtheta},0.005,{R=1,g=10,m=1})

q0=vec {1,0}
p0=vec {0,0.5}

cnv = win.New("paraboloid")

-- chamada quando a janela OpenGL é redimensionada
function cnv:Reshape(width, height)
  --print("resize")
  gl.Viewport(0, 0, width, height) -- coloca o viewport ocupando toda a janela
  gl.MatrixMode('PROJECTION')      -- seleciona matriz de projeção matrix
  gl.LoadIdentity()                -- carrega a matriz identidade
  gl.MatrixMode('MODELVIEW')       -- seleciona matriz de modelagem
  gl.LoadIdentity()                -- carrega a matriz identidade
end

points={}
points.x={}
points.y={}

function cnv:Display()
	--print("action")
  -- limpa a tela e o z-buffer
  gl.Clear('COLOR_BUFFER_BIT,DEPTH_BUFFER_BIT')
  gl.MatrixMode('MODELVIEW')       -- seleciona matriz de modelagem
  gl.LoadIdentity()         
  gl.PointSize(1.0)
  gl.Color(1,0,0)
  gl.Begin('POINTS')
  local n
  if #points.x<=100 then n=1 else n=#points.x-99 end
  for i=n,#points.x do
    gl.Vertex(points.x[i],points.y[i])
  end
  gl.End()
end

-- chamada quando a janela OpenGL é criada
function cnv:Init()
	--print("map")
  gl.ClearColor(0.0,0.0,0.0,0.0)                  -- cor de fundo preta
  gl.ClearDepth(1.0)                              -- valor do z-buffer
  gl.Disable('DEPTH_TEST')                         -- habilita teste z-buffer
  gl.Enable('CULL_FACE')                         
  gl.ShadeModel('FLAT')
end

-- chamada quando uma tecla é pressionada
function cnv:Keyboard(key,x,y)
    if key==27 then
        os.exit()
    end
end

function Step()
  local rho=q0:get(0)
  local theta=q0:get(1)
  local x,y=rho*math.cos(theta),rho*math.sin(theta)
  points.x[#points.x+1]=x
  points.y[#points.y+1]=y
  idyn(q0,p0)
  glut.PostRedisplay()
end

glut.IdleFunc(Step)

win.Loop()