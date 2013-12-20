package Groups;

use strict;

my %groupDesc = (
   'connection' => "Generic functions that affect the current connection.",
   'connection.data' => "Functions that allow you to store and retrieve data stored for the lifetime of the current connection.",  
   'counter' => "Functions for altering user defined counters.",
   'data' => "Functions that allow you to store information shared between all rules.",
   'event' => "Functions to generate custom events.",
   'geo' => "Functions for working out geographic location based on IP address.",
   'http' => "HTTP protocol-specific functions.",
   'http.cache' => "Functions affecting the HTTP cache.",
   'http.compress' => "Functions affecting the HTTP compression of this connection.",
   'http.request' => "Functions that allow you to send HTTP requests within TrafficScript rules.",
   'http.stream' => "Functions for streaming HTTP data.",
   'java' => "Functions relating to Java Extensions.",
   'lang' => "Standard functions, mostly for converting data types.",
   'log' => "Functions for writing to the event log.",
   'math' => "Mathematical functions for manipulating numbers.",
   'net.dns' => "DNS lookup functions.",
   'pool' => " Functions that allow you to look up and alter which pool the current request will be assigned to.",
   'rate' => "Functions that allow you to monitor and assign rate shaping classes.",
   'rate.use' => "Functions that conditionally activate a rate shaping class.",
   'request' => "Functions that allow you to access information about and modify the current request.",
   'resource' => "Functions that allow you to access files uploaded to the 'Extra Files' section of the traffic manager.",
   'response' => "Functions that allow you to access information about and modify the current response.",
   'rtsp' => "RTSP protocol-specific functions.",
   'rule' => "Functions relating to this rule.",
   'sip' => "SIP protocol-specific functions.",
   'slm' => "Functions for accessing information from the Service Level Monitoring class assigned to this connection.",
   'ssl' => "Functions relating to the encryption applied to the current connection.",
   'string' => "Functions for manipulating and encoding strings.",
   'string.gmtime' => "Time parsing functions.",
   'sys' => "Functions relating to the local machine.",
   'sys.gmtime' => "Date functions using Greenwich Mean Time.",
   'sys.localtime' => "Date functions using the local time of the system.",
   'sys.time' => "General date functions.",
   'xml' => "Functions for parsing and manipulating the eXtensible Markup Language.",
   'xml.validate' => "Functions for validating the eXtensible Markup Language.",
   'xml.xpath' => "Functions for preforming XPath queries on XML data.",
   'xml.xslt' => "XSLT transformation functions.",
);

sub Descriptions()
{
   return %groupDesc;
}



1;
