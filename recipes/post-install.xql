xquery version "3.0";

(:
 : MD 2025-06-15 - copied from eXist demo app
   and slightly adapted
   
   https://exist-db.org/exist/apps/fundocs/view.html?uri=http://exist-db.org/xquery/xmldb&location=java:org.exist.xquery.functions.xmldb.XMLDBModule&details=true
   
 :)
import module namespace xrest="http://exquery.org/ns/restxq/exist" at "java:org.exist.extensions.exquery.restxq.impl.xquery.exist.ExistRestXqModule";

(: The following external variables are set by the repo:deploy function :)

(: the target collection into which the app is deployed :)
declare variable $target external;

(: Register restxq modules. Should be done automatically, but there seems to be an occasional bug :)
xrest:register-module(xs:anyURI($target || "/modules/app.xql"))