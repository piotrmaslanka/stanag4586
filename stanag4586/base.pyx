import struct

STANAG_HEADER = struct.Struct('>HHLLHH')
STRUCT_H = struct.Struct('>H')
STRUCT_L = struct.Struct('>L')


cdef inline unsigned int checksum_16(bytes b):
    cdef:
        unsigned short counter = 0
        int byte
    for byte in b:
        counter += byte
    return counter

cdef inline unsigned int checksum_32(bytes b):
    cdef:
        unsigned int counter = 0
        int byte
    for byte in b:
        counter += byte
    return counter


cdef inline unsigned long checksum(bytes b, int checksum_length):
    cdef:
        unsigned long modulo
        unsigned long counter = 0
        int byte
    if checksum_length == 0:
        return 0
    elif checksum_length == 2:
        return checksum_16(b)
    elif checksum_length == 4:
        return checksum_32(b)


cdef class BaseDatagram:
    """
    A base STANAG 4586 frame

    :ivar payload: (bytes) message payload
    :ivar sequence_no: (int) sequence no
    :ivar source_id: (int) source ID
    :ivar destination_id: (int) destination ID
    :ivar message_type: (int) message type
    :ivar message_properties: (int) message properties
    """
    def __init__(self, bytes payload, unsigned int sequence_no,
                 unsigned int source_id, unsigned int destination_id,
                 unsigned short message_type, unsigned short message_properties):
        self.payload = payload
        self.sequence_no = sequence_no
        self.source_id = source_id
        self.destination_id = destination_id
        self.message_type = message_type
        self.message_properties = message_properties

    def __bytes__(self):
        return self.to_bytes()

    cpdef int checksum_length(self):
        """Return checksum length in bytes"""
        return ((self.message_properties >> 6) & 3) << 1

    cpdef bytes get_body(self):
        """
        Return the message without the checksum
        """
        data = STANAG_HEADER.pack(self.sequence_no, len(self.payload),
                                  self.source_id, self.destination_id,
                                  self.message_type, self.message_properties) + self.payload
        return data + self.payload

    def __len__(self):
        return self.get_length()

    cpdef int get_length(self):
        """Return the length of this message"""
        return STANAG_HEADER.calcsize() + len(self.payload) + self.checksum_length()

    cpdef bytes to_bytes(self):
        """Convert the message to bytes"""
        cdef:
            bytes body = self.get_body()
            int checksum_length = self.checksum_length()

        if checksum_length == 0:
            return body

        cdef unsigned long check_sum = checksum(body, checksum_length)

        if checksum_length == 2:
            return body + STRUCT_H.pack(check_sum)
        elif checksum_length == 4:
            return body + STRUCT_L.pack(check_sum)

