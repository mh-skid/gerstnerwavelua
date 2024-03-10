local Quadtree = {}
Quadtree.__index = Quadtree

function Quadtree.new(GridStart, GridEnd, Children, Depth)
	local self = setmetatable({}, Quadtree)

	self.Start = GridStart
	self.End = GridEnd
	self.Grid = self.End-self.Start
	self:Refresh()
	--
	self.Children = self:GetChildrenInQuad(Children)

	self.Depth = Depth

	if self.Depth > 0 then
		self.Depth = self.Depth-1
		self:AddSubtrees()
	end

	return self
end

function Quadtree:Refresh()
	self.Quadmiddle = m.CV3(self.Start.X+self.Grid.X/2,0,self.Start.Y+self.Grid.Y/2)
	self.Radius = math.sqrt((self.Grid.X/2)^2+(self.Grid.Y/2)^2)
end

function Quadtree:AddSubtrees()
	self.HasSubtrees = true

	local Grid = self.Grid

	self.A = Quadtree.new(self.Start,self.End-Grid/2, self.Children, self.Depth)
	self.B = Quadtree.new(self.Start+Grid/2,self.End, self.Children, self.Depth)
	self.C = Quadtree.new(self.Start+m.CV2(Grid.X/2,0),self.End-m.CV2(0,Grid.Y/2), self.Children, self.Depth)
	self.D = Quadtree.new(self.Start+m.CV2(0,Grid.Y/2),self.End-m.CV2(Grid.X/2,0), self.Children, self.Depth)

	self.Children = nil
end

function IsInFrustum(Planes, Middle, Radius)
	for i,p in pairs(Planes) do
		if (Middle:Dot(p[1]) + p[2] + Radius <= 0) then
			return false
		end
	end
	
	return true
end

function Quadtree:findWithinFrustum(Planes, Tbl)
	Tbl = Tbl or {}
	
	if IsInFrustum(Planes, self.Quadmiddle, self.Radius) then
		self.Static = false
		
		if self.HasSubtrees then
			self.A:findWithinFrustum(Planes, Tbl)
			self.B:findWithinFrustum(Planes, Tbl)
			self.C:findWithinFrustum(Planes, Tbl)
			self.D:findWithinFrustum(Planes, Tbl)
		else
			table.insert(Tbl, self.Children)
		end
	else
		self:ResetTransform()
	end

	return Tbl
end

function Quadtree:ResetTransform()
	if not self.Static then
		self.Static = true
		
		if self.HasSubtrees then
			self.A:ResetTransform()
			self.B:ResetTransform()
			self.C:ResetTransform()
			self.D:ResetTransform()
		else
			for i,v in ipairs(self.Children) do
				v.Transform = CFrame.new()
			end
		end
	end
end

function Quadtree:Shift(x,y)
	local shift = m.CV2(x,y)
	self.Start = self.Start+shift
	self.End = self.End+shift
	self:Refresh()
	
	if self.HasSubtrees then
		self.A:Shift(x,y)
		self.B:Shift(x,y)
		self.C:Shift(x,y)
		self.D:Shift(x,y)
	end
end

function Quadtree:GetChildrenInQuad(Children)
	local newChildren = {}
	for i,v in ipairs(Children) do
		if (v.WorldPosition.X >= self.Start.X and v.WorldPosition.X <= self.End.X)
			and (v.WorldPosition.Z >= self.Start.Y and v.WorldPosition.Z <= self.End.Y) then

			table.insert(newChildren, v)
		end
	end

	return newChildren
end

return Quadtree
