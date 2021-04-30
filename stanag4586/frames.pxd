cdef class BaseSTANAGPayload:
    cdef:
        bytearray presence_field
        public unsigned long timestamp

    cpdef length(self)
    cpdef to_bytes(self)
    cpdef bint has_field(self, int i)
    cpdef void set_field(self, int i, bint has)

