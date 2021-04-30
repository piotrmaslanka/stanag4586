cdef class BaseDatagram:
    cdef:
        readonly bytes payload
        public unsigned int sequence_no
        public unsigned int source_id
        public unsigned int destination_id
        public unsigned short message_type
        public unsigned short message_properties

    cpdef int checksum_length(self)
    cpdef bytes get_body(self)
    cpdef bytes to_bytes(self)
