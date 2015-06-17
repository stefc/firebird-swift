//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//


#import <Firebird/ibase.h>

// extern void isc_get_client_version( char *);

extern int  isc_get_client_major_version();
extern int  isc_get_client_minor_version();

// extern *char[5] isc_attach_database(unsigned char *, short, const unsigned char *, unsigned char *, short, const unsigned char *);



