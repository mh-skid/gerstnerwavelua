local gerstner = {}
local m = require("VECTORS") --gay shit fuck piss cum oh my god 😭😭😭😭😭


function gerstner.GetTransform(WaveData, GridP, RunTime)
	local p = m.CV3()
	for i,Wave in pairs(WaveData) do
		p = p + gerstner.Calculate(Wave, GridP, RunTime)
	end

	return p
end
function gerstner.GetHeightAndNormal(WaveData, GridP, RunTime)
	local p = m.CV3()
	local tan = m.CV3(1,0,0)
	local bi = m.CV3(0,0,1)

	for i,Wave in pairs(WaveData) do
		local _p, _tan, _bi = gerstner.Calculate(Wave, GridP, RunTime, true)
		p = p + _p
		tan = tan + _tan
		bi = bi + _bi
	end

	return p, tan, bi
end
function gerstner.Calculate(Wave, GridP, RunTime, Ret)
	local steepness = Wave.z
	local wavelength = Wave.w
	local k = (math.pi*2)/wavelength
	local c = math.sqrt(9.8/k)
	local d = m.CV2(Wave.x, Wave.y).unit
	local f = k*(d:Dot(m.CV2(GridP.x,GridP.z)) - c * RunTime) -- its like dotproduct(d)
	local a = steepness/k

	local cosf = math.cos(f)
	local sinf = math.sin(f)
	--
	local tangent, binormal

	if Ret then
		tangent = m.CV3(-d.x*d.x*(steepness*sinf), d.x*(steepness*cosf), -d.x*d.y*(steepness*sinf))
		binormal = m.CV3(-d.x*d.y*(steepness*sinf), d.y*(steepness*cosf), -d.y*d.y*(steepness*sinf))
	end
	--
	return m.CV3(d.x*(a*cosf), a*sinf, d.y*(a*cosf)), tangent, binormal
end

return gerstner
