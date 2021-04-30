cdef enum:
    NO_ACK = 0
    ACK = 0x8000
    STANAG_EDITION_3 = 0x1E00
    NO_CHECKSUM = 0X0000
    CHECKSUM_16BIT = 0x0040
    CHECKSUM_32BIT = 0x0080



cdef class BaseDatagram:
    cdef:
        public bytes payload
        public unsigned int sequence_no
        public unsigned int source_id
        public unsigned int destination_id
        public unsigned short message_type
        public unsigned short message_properties

    cpdef int checksum_length(self)
    cpdef bytes get_body(self)
    cpdef bytes to_bytes(self)
    cpdef int get_length(self)

cpdef list parse_datagrams(bytearray b)
