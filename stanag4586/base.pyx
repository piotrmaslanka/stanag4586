import struct
from .base cimport NO_ACK, ACK, STANAG_EDITION_3, NO_CHECKSUM, \
    CHECKSUM_16BIT, CHECKSUM_32BIT
from .frames cimport BaseSTANAGPayload

STANAG_HEADER = struct.Struct('>HHLLHH')
STRUCT_H = struct.Struct('>H')
STRUCT_L = struct.Struct('>L')


MP_NO_ACK = NO_ACK                     #: No acknowledgement is to be expected for this command
MP_ACK = ACK                           #: Acknowledgement is expected for this command
MP_STANAG_EDITION_3 = STANAG_EDITION_3 #: This is to be included in each STANAG 4586 datagram
MP_NO_CHECKSUM = NO_CHECKSUM           #: This datagram has no checksum
MP_CHECKSUM_16BIT = CHECKSUM_16BIT     #: This datagram has a 16-bit checksum
MP_CHECKSUM_32BIT = CHECKSUM_32BIT     #: This datagram has a 32-bit checksum


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

    At given time you might provide either a payload or a data_payload

    :ivar payload: (bytes) message payload
    :ivar sequence_no: (int) sequence no
    :ivar source_id: (int) source ID
    :ivar destination_id: (int) destination ID
    :ivar message_type: (int) message type
    :ivar message_properties: (int) message properties
    """
    def __init__(self, unsigned int sequence_no,
                 unsigned int source_id, unsigned int destination_id,
                 unsigned short message_type, unsigned short message_properties,
                 bytes payload=None,
                 BaseSTANAGPayload data_payload=None):
        assert bool(payload) ^ bool(data_payload), 'Both payloads given!'
        self.payload = payload
        self.sequence_no = sequence_no
        self.source_id = source_id
        self.destination_id = destination_id
        self.message_type = message_type
        self.message_properties = message_properties
        self.data_payload = data_payload

    def __bytes__(self):
        return self.to_bytes()

    cpdef int checksum_length(self):
        """Return checksum length in bytes"""
        return ((self.message_properties >> 6) & 3) << 1

    cpdef int get_payload_length(self):
        """Return payload's length"""
        if self.payload is None:
            return self.data_payload.length()
        else:
            return len(self.payload)

    cpdef bytes get_payload(self):
        """Return the payload, as bytes"""
        if self.payload is None:
            return self.data_payload.to_bytes()
        else:
            return self.payload

    cpdef bytes get_body(self):
        """
        Return the message without the checksum
        """
        cdef:
            int payload_length = self.get_payload_length()
            bytes data = STANAG_HEADER.pack(self.sequence_no, payload_length,
                                             self.source_id, self.destination_id,
                                             self.message_type, self.message_properties)
        return data + self.get_payload()

    def __len__(self):
        return self.get_length()

    cpdef int get_length(self):
        """Return the length of this message"""
        return STANAG_HEADER.size + self.get_payload_length() + self.checksum_length()

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


cpdef list parse_datagrams(bytearray b):
    """
    Return a list of BaseDatagrams that can be parsed from this UDP packet
    
    :param b: data to examine 
    :return: a list of datagrams
    :rtype: tp.List[BaseDatagram]
    """
    cdef:
        int offset = 0
        BaseDatagram bdr
        list output = []
    while b[offset:]:
        try:
            bdr = parse_frame(b[offset:])
            output.append(bdr)
            offset += bdr.get_length()
        except ValueError:
            return output
    return output


cdef inline BaseDatagram parse_frame(bytearray b):
    cdef:
        bytes payload
        unsigned int sequence_no,
        unsigned int source_id
        unsigned short payload_length
        unsigned int destination_id,
        unsigned short message_type
        unsigned short message_properties
        unsigned int checksum
        unsigned int size_p
    try:
        sequence_no, payload_length, source_id, destination_id, \
            message_type, message_properties = STRUCT_H.unpack(b[:STANAG_HEADER.size])
    except struct.error:
        raise ValueError()
    size_p = STANAG_HEADER.size + payload_length
    payload = b[STANAG_HEADER.size:size_p]

    if message_properties & CHECKSUM_16BIT:
        checksum, = STRUCT_H.unpack(b[size_p:size_p+2])
        if checksum != checksum_16(b[:size_p]):
            raise ValueError()
    elif message_properties & CHECKSUM_32BIT:
        checksum, = STRUCT_L.unpack(b[size_p:size_p+2])
        if checksum != checksum_32(b[:size_p]):
            raise ValueError()

    return BaseDatagram(sequence_no, source_id, destination_id,
                        message_type, message_properties,
                        payload)
