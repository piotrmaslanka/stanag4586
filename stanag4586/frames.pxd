cdef class BaseSTANAGPayload:
    cdef:
        bytearray presence_field
        public unsigned long timestamp

    cpdef int length(self) except -1
    cpdef bytes to_bytes(self)
    cpdef bint has_field(self, int i)
    cpdef void set_field(self, int i, bint has)
    cpdef int get_field_count(self)
