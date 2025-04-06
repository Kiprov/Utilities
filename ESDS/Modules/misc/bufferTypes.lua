export type baseBufferType = {
	Write: (buff:buffer,offset:number,val:any)->(buffer,number),
	Read: (buff:buffer,offset:number)->(any,number)
}
local bufferTypes:{[string]:baseBufferType} = {} do
	local function extendBufferBy(buff:buffer,extend:number):buffer
		local newBuffer = buffer.create(buffer.len(buff)+extend)
		buffer.copy(newBuffer,0,buff,0)
		return newBuffer
	end

	bufferTypes.UInt8 = table.freeze({
		Write = function(buff:buffer,offset:number,val:number):(buffer,number)
			local b = extendBufferBy(buff,1)
			buffer.writeu8(b,offset,val)
			return b,offset+1
		end,
		Read = function(buff:buffer,offset:number):(number,number)
			return buffer.readu8(buff,offset),offset+1
		end
	})
	bufferTypes.Int8 = table.freeze({
		Write = function(buff:buffer,offset:number,val:number):(buffer,number)
			local b = extendBufferBy(buff,1)
			buffer.writei8(b,offset,val)
			return b,offset+1
		end,
		Read = function(buff:buffer,offset:number):(number,number)
			return buffer.readi8(buff,offset),offset+1
		end
	})

	bufferTypes.UInt16 = table.freeze({
		Write = function(buff:buffer,offset:number,val:number):(buffer,number)
			local b = extendBufferBy(buff,2)
			buffer.writeu16(b,offset,val)
			return b,offset+2
		end,
		Read = function(buff:buffer,offset:number):(number,number)
			return buffer.readu16(buff,offset),offset+2
		end
	})
	bufferTypes.Int16 = table.freeze({
		Write = function(buff:buffer,offset:number,val:number):(buffer,number)
			local b = extendBufferBy(buff,2)
			buffer.writei16(b,offset,val)
			return b,offset+2
		end,
		Read = function(buff:buffer,offset:number):(number,number)
			return buffer.readi16(buff,offset),offset+2
		end
	})

	bufferTypes.UInt32 = table.freeze({
		Write = function(buff:buffer,offset:number,val:number):(buffer,number)
			local b = extendBufferBy(buff,4)
			buffer.writeu32(b,offset,val)
			return b,offset+4
		end,
		Read = function(buff:buffer,offset:number):(number,number)
			return buffer.readu32(buff,offset),offset+4
		end
	})
	bufferTypes.Int32 = table.freeze({
		Write = function(buff:buffer,offset:number,val:number):(buffer,number)
			local b = extendBufferBy(buff,4)
			buffer.writei32(b,offset,val)
			return b,offset+4
		end,
		Read = function(buff:buffer,offset:number):(number,number)
			return buffer.readi32(buff,offset),offset+4
		end
	})

	bufferTypes.Float32 = table.freeze({
		Write = function(buff:buffer,offset:number,val:number):(buffer,number)
			local b = extendBufferBy(buff,4)
			buffer.writef32(b,offset,val)
			return b,offset+4
		end,
		Read = function(buff:buffer,offset:number):(number,number)
			return buffer.readf32(buff,offset),offset+4
		end
	})
	bufferTypes.Float64 = table.freeze({
		Write = function(buff:buffer,offset:number,val:number):(buffer,number)
			local b = extendBufferBy(buff,8)
			buffer.writef64(b,offset,val)
			return b,offset+8
		end,
		Read = function(buff:buffer,offset:number):(number,number)
			return buffer.readf64(buff,offset),offset+8
		end
	})

	bufferTypes.String = table.freeze({
		Write = function(buff:buffer,offset:number,val:string):(buffer,number)
			local len = string.len(val)
			local buff,offset = bufferTypes.UInt32.Write(buff,offset,len)
			local b = extendBufferBy(buff,len)
			buffer.writestring(b,offset,val,len)
			return b,offset+len
		end,
		Read = function(buff:buffer,offset:number):(string,number)
			local len,offset = bufferTypes.UInt32.Read(buff,offset)
			return buffer.readstring(buff,offset,len),offset+len
		end
	})

	bufferTypes.Boolean = table.freeze({
		Write = function(buff:buffer,offset:number,val:boolean):(buffer,number)
			return bufferTypes.UInt8.Write(buff,offset,val and 1 or 0)
		end,
		Read = function(buff:buffer,offset:number):(boolean,number)
			local boolNum,offset = bufferTypes.UInt8.Read(buff,offset)
			return boolNum == 1,offset
		end
	})
end

return bufferTypes
