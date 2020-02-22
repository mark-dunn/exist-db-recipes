<xsl:stylesheet xmlns:xforms="http://www.w3.org/2002/xforms" xmlns:in="http://www.w3.org/2002/xforms-instance" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:js="http://saxonica.com/ns/globalJS" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:ixsl="http://saxonica.com/ns/interactiveXSLT" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:math="http://www.w3.org/2005/xpath-functions/math" xmlns:map="http://www.w3.org/2005/xpath-functions/map" exclude-result-prefixes="xs math xforms" extension-element-prefixes="ixsl" version="3.0">

    <xsl:output method="html" encoding="utf-8" omit-xml-declaration="no" indent="no" doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"/>


    <xsl:template name="xformsjs-main">
        <xsl:param name="xforms-doc" as="document-node()?" select="()"/>
        <xsl:param name="xforms-file" as="xs:string?"/>
        <xsl:param name="instance-xml" as="document-node()?"/>
        <xsl:param name="xFormsId" select="'#xForm'" as="xs:string"/>
        <xsl:param name="xforms-instance-id" select="'#xforms-jinstance'"/>

        <xsl:variable name="xforms-doci" select="                 if (empty($xforms-doc)) then                     doc($xforms-file)                 else                     $xforms-doc" as="document-node()?"/>

        <xsl:variable name="instance-doc">
            <xsl:choose>
                <xsl:when test="empty($instance-xml)">
                    <xsl:copy-of select="$xforms-doci/xforms:xform/xforms:model/xforms:instance/*"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy-of select="$instance-xml"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="bindings" as="map(xs:string, node())">
            <xsl:map>
                <xsl:for-each select="$xforms-doci/xforms:xform/xforms:model/xforms:bind">
                    <!-- [exists(@type)] -->
                    <xsl:variable name="xnodeset" as="node()?">
                        <xsl:evaluate xpath="./@nodeset" context-item="$instance-doc"/>
                    </xsl:variable>
                    <!--  <xsl:message>xnodeset<xsl:value-of select="serialize($xnodeset)"/></xsl:message> -->
                    <xsl:if test="empty($xnodeset)">
                        <xsl:message>xformsbind is empty nodeste = <xsl:value-of select="serialize(.)"/>
                        </xsl:message>
                    </xsl:if>
                    <xsl:map-entry key="                             xs:string(if (exists(@id)) then                                 @id                             else                                 @nodeset)" select="."/>
                    <!--<xsl:map-entry key="generate-id($xnodeset)" select="."/> -->
                    <!-- <xsl:map-entry key="generate-id($xnodeset)" select="resolve-QName(./@type, .)"/> -->
                </xsl:for-each>
            </xsl:map>
        </xsl:variable>

        <xsl:variable name="submissions" as="map(xs:string, xs:string)">
            <xsl:map>
                <xsl:for-each select="$xforms-doci/xforms:xform/xforms:model/xforms:submission">
                    <xsl:map-entry key="xs:string(@ref)" select="xs:string(@action)"/>
                </xsl:for-each>
            </xsl:map>
        </xsl:variable>
        <!-- <xsl:message>
            instance-xml=<xsl:value-of select="serialize($instance-doc)"/>
            
        </xsl:message>
        <xsl:message>
            instance-map=<xsl:value-of select="serialize(xforms:convert-xml-to-jxml($instance-doc))"/>
           
        </xsl:message>-->

        <xsl:if test="exists($instance-doc)">
            <!--<xsl:message>$instance-doc <xsl:value-of select="serialize($instance-doc)"/></xsl:message>
            <xsl:message>converted $instance-doc <xsl:value-of select="serialize(xforms:convert-xml-to-jxml($instance-doc))"/></xsl:message>-->
            <xsl:variable name="wrapped-instance">
                <wrapper>
                    <xsl:sequence select="$instance-doc"/>
                </wrapper>
            </xsl:variable>
            <xsl:result-document href="{$xforms-instance-id}" method="ixsl:replace-content">
                <xsl:value-of select="xml-to-json(xforms:convert-xml-to-jxml($wrapped-instance))"/>
            </xsl:result-document>
        </xsl:if>

        <xsl:message> instance-jxml=<xsl:value-of select="serialize(xforms:convert-json-to-xml(ixsl:page()//script[@id = 'xforms-jinstance']/text()))"/>
        </xsl:message>

        <xsl:result-document href="{$xFormsId}" method="ixsl:replace-content">
            <xsl:apply-templates select="$xforms-doci/xforms:xform">
                <xsl:with-param name="instance1" select="$instance-doc"/>
                <xsl:with-param name="bindings" select="$bindings" as="map(xs:string, node())"/>
                <xsl:with-param name="submissions" select="$submissions" as="map(xs:string, xs:string)"/>
            </xsl:apply-templates>
        </xsl:result-document>

    </xsl:template>

    <xsl:template match="input" mode="ixsl:onchange">
        <xsl:message>Input box changed1 <xsl:value-of select="@value"/>
        </xsl:message>
    </xsl:template>

    <xsl:function name="xforms:check-required-fields" as="item()*">
        <xsl:param name="updatedInstanceXML"/>

        <xsl:variable name="required-fieldsi" select="ixsl:page()//*[@data-required]" as="item()*"/>



        <xsl:for-each select="$required-fieldsi">

            <xsl:variable name="resulti">
                <xsl:evaluate xpath="concat('boolean(normalize-space(', @id, '))', '=', @id, '/', @data-required)" context-item="$updatedInstanceXML"/>
            </xsl:variable>
            <xsl:sequence select="                     if ($resulti = 'false') then                         .                     else                         ()"/>
        </xsl:for-each>



    </xsl:function>

    <xsl:template match="button[exists(@data-submit)]" mode="ixsl:onclick">
        <!-- XML Map rep of JSON map -->
        <xsl:variable name="instanceXML" select="xforms:convert-json-to-xml(ixsl:page()//script[@id = 'xforms-jinstance']/text())"/>

        <xsl:variable name="updatedInstanceXML">

            <xsl:apply-templates select="$instanceXML" mode="form-check-initial"/>
        </xsl:variable>


        <xsl:variable name="required-fieldsi" select="ixsl:page()//*[@data-required]" as="item()*"/>

        <xsl:variable name="required-fields-check" as="item()*" select="xforms:check-required-fields($updatedInstanceXML)"/>




        <xsl:variable name="action">
            <xsl:value-of select="@data-submit"/>
        </xsl:variable>



        <xsl:choose>
            <xsl:when test="count($required-fields-check) = 0">
                <xsl:sequence select="js:submitXMLorderWithUrl(serialize($action), serialize($updatedInstanceXML), 'orderResponse')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="error-message">
                    <xsl:for-each select="$required-fields-check">
                        <xsl:variable name="curNode" select="."/>

                        <xsl:value-of select="concat('Value error see: ', serialize($curNode/@id), '&#xA;')"/>

                    </xsl:for-each>
                </xsl:variable>
                <xsl:sequence select="ixsl:call(ixsl:window(), 'alert', [serialize($error-message)])"/>
            </xsl:otherwise>
        </xsl:choose>



    </xsl:template>

    <xsl:template match="xforms:model"/>

    <xsl:template match="/">
        <xsl:apply-templates select="xforms:xform"/>

    </xsl:template>

    <!--    <xsl:template name="generate-xform">
        <xsl:param name="xform-src"/>
        <xsl:apply-templates select="$xform-src" />
        
    </xsl:template>-->

    <xsl:template match="xforms:xform">
        <xsl:param name="instance1"/>
        <xsl:param name="bindings" as="map(xs:string, node())" select="map{}"/>
        <xsl:param name="submissions" as="map(xs:string, xs:string)" select="map{}"/>

        <xsl:apply-templates select="*">
            <xsl:with-param name="instance1" select="$instance1"/>
            <xsl:with-param name="bindings" select="$bindings"/>
            <xsl:with-param name="submissions" select="$submissions"/>
        </xsl:apply-templates>
    </xsl:template>

    <xsl:template match="xhtml:html | html">
        <html>
            <xsl:copy-of select="@*"/>
            <head>
                <xsl:copy-of select="xhtml:head/@* | head/@*"/>
                <meta http-equiv="Content-Type" content="text/html;charset=utf-8"/>
                <xsl:for-each select="xhtml:head/xhtml:meta[string(@http-equiv) != 'Content-Type'] | head/meta[string(@http-equiv) != 'Content-Type']">
                    <meta>
                        <xsl:copy-of select="@*"/>
                    </meta>
                </xsl:for-each>


                <xsl:copy-of select="script"/>
            </head>
            <body>
                <xsl:apply-templates select="body/*"/>
            </body>

        </html>

    </xsl:template>

    <xsl:template match="xforms:input">
        <xsl:param name="instance1" as="node()?" select="()"/>
        <xsl:param name="bindings" as="map(xs:string, node())" select="map{}"/>
        <!-- nodeset - used when the xforms:input is contained in a xforms:repeat to keep track of the entire instance document -->
        <xsl:param name="nodeset" as="xs:string" select="''"/>
        <xsl:message>xforms:input=<xsl:value-of select="serialize($instance1)"/> ref= <xsl:value-of select="@ref"/>, <xsl:value-of select="serialize(.)"/> nodeset = <xsl:value-of select="$nodeset"/>
        </xsl:message>
        <xsl:variable name="refi" select="concat($nodeset, @ref)"/>
        <xsl:variable name="in-node" as="node()?">
            <xsl:if test="(exists(@ref))">
                <xsl:evaluate xpath="$refi" context-item="$instance1"/>
            </xsl:if>
        </xsl:variable>

        <xsl:apply-templates select="*"/>

        <xsl:variable name="hints" select="xforms:hint/text()"/>
        <xsl:variable name="ref-binding" as="xs:string">
            <xsl:choose>
                <xsl:when test="exists(@ref)">
                    <xsl:value-of select="@ref"/>
                </xsl:when>
                <xsl:when test="exists(@bind)">
                    <xsl:value-of select="@bind"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="''"/>
                </xsl:otherwise>
            </xsl:choose>

        </xsl:variable>

        <xsl:message>xforms:ref-binding= <xsl:value-of select="$ref-binding"/>
        </xsl:message>
        <xsl:variable name="bindingi" select="                 if (empty($ref-binding)) then                     ()                 else                     map:get($bindings, $ref-binding)" as="node()?"/>
        <input>
            <xsl:if test="exists($bindingi) and exists($bindingi/@required)">
                <xsl:attribute name="data-required" select="$bindingi/@required"/>
            </xsl:if>
            <xsl:if test="exists($bindingi) and exists($bindingi/@relevant)">
                <xsl:attribute name="data-relevant" select="$bindingi/@relevant"/>
            </xsl:if>
            <xsl:if test="exists($bindingi)">
                <xsl:message>binding found! : <xsl:value-of select="serialize($bindingi)"/>
                </xsl:message>
            </xsl:if>
            <xsl:choose>

                <xsl:when test="                         if (exists($bindingi)) then                             xs:QName($bindingi/@type) eq xs:QName('xs:date')                         else                             false()">
                    <xsl:attribute name="type" select="'date'"/>
                </xsl:when>
                <xsl:when test="                         if (exists($bindingi)) then                             xs:QName($bindingi/@type) eq xs:QName('xs:time')                         else                             false()">
                    <xsl:attribute name="type" select="'time'"/>
                </xsl:when>
                <xsl:when test="                         if (exists($bindingi)) then                             xs:QName($bindingi/@type) eq xs:QName('xs:boolean')                         else                             false()">
                    <xsl:attribute name="type" select="'checkbox'"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="type" select="'text'"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:if test="exists($hints)">
                <xsl:attribute name="placeholder" select="$hints"/>
            </xsl:if>
            <xsl:if test="exists(@size)">
                <xsl:attribute name="size" select="@size"/>
            </xsl:if>
            <xsl:attribute name="data-ref" select="$refi"/>
            <xsl:attribute name="value">
                <xsl:if test="exists($instance1) and exists(@ref)">
                    <xsl:evaluate xpath="concat($refi, '/text()')" context-item="$instance1"/>
                </xsl:if>
            </xsl:attribute>
        </input>
    </xsl:template>


    <xsl:template match="xforms:textarea" priority="2">
        <xsl:param name="instance1" as="node()?" select="()"/>
        <xsl:param name="bindings" as="map(xs:string, node())" select="map{}"/>
        <xsl:param name="nodeset" as="xs:string" select="''"/>
        <xsl:apply-templates select="*"/>

        <xsl:variable name="hints" select="xforms:hint/text()"/>

        <textarea>
            <xsl:copy-of select="@*[local-name() != 'ref']"/>
            <xsl:attribute name="data-ref" select="concat($nodeset, @ref)"/>
            <xsl:choose>
                <xsl:when test="exists($instance1) and exists(@ref)">


                    <xsl:evaluate xpath="concat(@ref, '/text()')" context-item="$instance1"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text/>  </xsl:otherwise>
            </xsl:choose>
            <xsl:if test="exists($hints)">
                <xsl:attribute name="placeholder" select="$hints"/>
            </xsl:if>
        </textarea>
    </xsl:template>

    <xsl:template match="xforms:hint"> </xsl:template>

    <xsl:template match="xforms:select1 | xforms:select">
        <xsl:param name="instance1" as="node()?" select="()"/>
        <xsl:param name="bindings" as="map(xs:string, node())" select="map{}"/>
        <!-- nodeset - used when the xforms:input is contained in a xforms:repeat to keep track of the entire instance document -->
        <xsl:param name="nodeset" as="xs:string" select="''"/>
        <!-- TODO: bindins need to be applied to the select/select1 element -->
        <xsl:apply-templates select="xforms:label"/>
        <select>
            <xsl:copy-of select="@*[local-name() != 'ref']"/>
            <xsl:if test="exists($instance1) and exists(@ref)">
                <xsl:attribute name="data-ref" select="concat($nodeset, @ref)"/>
            </xsl:if>
            <xsl:if test="local-name() = 'select'">
                <xsl:attribute name="multiple">true</xsl:attribute>
                <xsl:attribute name="size">
                    <xsl:value-of select="count(descendant::xforms:item)"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates select="node()" mode="item">
                <xsl:with-param name="instance1" select="$instance1"/>
                <xsl:with-param name="nodeset" select="$nodeset"/>
            </xsl:apply-templates>

        </select>



    </xsl:template>


    <xsl:template match="(node() | @*)">
        <xsl:param name="instance1" as="node()?" select="()"/>
        <xsl:param name="bindings" as="map(xs:string, node())" select="map{}"/>
        <xsl:param name="submissions" as="map(xs:string, xs:string)" select="map{}"/>
        <!-- nodeset - used when the xforms:input is contained in a xforms:repeat to keep track of the entire instance document -->
        <xsl:param name="nodeset" as="xs:string" select="''"/>
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates select="node()">
                <xsl:with-param name="instance1" select="$instance1"/>
                <xsl:with-param name="bindings" select="$bindings"/>
                <xsl:with-param name="submissions" select="$submissions" as="map(xs:string, xs:string)"/>
                <xsl:with-param name="nodeset" select="$nodeset" as="xs:string"/>
            </xsl:apply-templates>

        </xsl:copy>
    </xsl:template>



    <xsl:template match="text()[((ancestor::xforms:model))]"/>



    <xsl:template match="xforms:label">
        <xsl:param name="instance1" as="node()?" select="()"/>
        <label>
            <xsl:choose>
                <xsl:when test="count(./node()) &gt; 0">
                    <xsl:apply-templates select="node()"/>
                </xsl:when>
                <xsl:otherwise> <xsl:text/>
                </xsl:otherwise>
            </xsl:choose>
        </label>
    </xsl:template>

    <xsl:template match="xforms:item" mode="item">
        <xsl:param name="instance1" as="node()?" select="()"/>
        <xsl:param name="nodeset" as="xs:string" select="''"/>
        <xsl:variable name="selectedVar">
            <xsl:evaluate xpath="concat($nodeset, ../@ref)" context-item="$instance1"/>
        </xsl:variable>


        <option value="{xforms:value}">
            <xsl:if test="exists($instance1) and $selectedVar = xforms:value/text()">
                <xsl:attribute name="selected" select="$selectedVar"/>
            </xsl:if>

            <xsl:value-of select="xforms:label"/>
        </option>

    </xsl:template>

    <xsl:template match="xforms:repeat">
        <xsl:param name="instance1" as="node()?" select="()"/>
        <xsl:param name="bindings" as="map(xs:string, node())" select="map{}"/>
        <xsl:param name="submissions" as="map(xs:string, xs:string)" select="map{}"/>
        <xsl:variable name="context" select="."/>
        <xsl:variable name="nodeseti" select="@nodeset"/>

        <xsl:if test="exists($instance1)">
            <xsl:variable name="selectedRepeatVar">
                <xsl:evaluate xpath="@nodeset" context-item="$instance1"/>
            </xsl:variable>
            
            <xsl:if test="exists($selectedRepeatVar)">               
                <div data-ref="{@nodeset}" data-count="{count($selectedRepeatVar/*)}">

                    <xsl:for-each select="$selectedRepeatVar/*">
                        <div>
                        <xsl:apply-templates select="$context/*">
                            <xsl:with-param name="instance1" select="$instance1"/>

                            <xsl:with-param name="nodeset" select="concat($nodeseti, '[', position(), ']', '/')"/>
                            <xsl:with-param name="bindings" select="$bindings"/>
                            <xsl:with-param name="submissions" select="$submissions"/>
                        </xsl:apply-templates>
                        </div>
                    </xsl:for-each>
                </div>
            </xsl:if>

        </xsl:if>


    </xsl:template>

    <xsl:template match="xforms:submit">
        <xsl:param name="instance1" as="node()?" select="()"/>
        <xsl:param name="bindings" as="map(xs:string, node())" select="map{}"/>
        <xsl:param name="submissions" as="map(xs:string, xs:string)" select="map{}"/>
        <xsl:variable name="innerbody">
            <xsl:choose>
                <xsl:when test="xforms:label">
                    <xsl:apply-templates select="node()">
                        <xsl:with-param name="instance1" select="$instance1"/>
                        <xsl:with-param name="bindings" select="$bindings"/>
                    </xsl:apply-templates>

                </xsl:when>
                <xsl:otherwise> </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>


        <xsl:choose>
            <xsl:when test="@appearance = 'minimal'">
                <a>
                    <xsl:copy-of select="$innerbody"/>
                </a>
            </xsl:when>
            <xsl:otherwise>
                <button type="button">
                    <xsl:copy-of select="@*[local-name() != 'ref']"/>
                    <xsl:if test="exists(@id) and map:contains($submissions, @id)">
                        <xsl:attribute name="data-action" select="map:get($submissions, @id)"/>
                    </xsl:if>
                    <xsl:copy-of select="$innerbody"/>
                </button>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>

    <xsl:template match="xforms:trigger">
        <xsl:param name="instance1" as="node()?" select="()"/>
        <xsl:param name="bindings" as="map(xs:string, node())" select="map{}"/>
        <xsl:param name="submissions" as="map(xs:string, xs:string)" select="map{}"/>
        <xsl:variable name="innerbody">
            <xsl:choose>
                <xsl:when test="xforms:label">
                    <xsl:apply-templates select="node()">
                        <xsl:with-param name="instance1" select="$instance1"/>
                        <xsl:with-param name="bindings" select="$bindings"/>
                    </xsl:apply-templates>

                </xsl:when>
                <xsl:otherwise> </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="myid" select="                 if (exists(@id)) then                     @id                 else                     generate-id()"/>

        <xsl:variable name="actions">
            <action>
                <xsl:choose>
                    <xsl:when test="exists(xforms:action)">
                        <xsl:copy-of select="@*"/>
                    </xsl:when>
                </xsl:choose>
                <xsl:for-each select="xforms:setvalue | xforms:insert | xforms:delete | xforms:action | xforms:toggle | xforms:send | xforms:setfocus | xforms:setindex | xforms:load | xforms:message | xforms:dispatch | xforms:rebuild | xforms:reset | xforms:show | xforms:hide | xforms:script | xforms:unload">
                    <xsl:apply-templates select="." mode="xforms-action"/>
                </xsl:for-each>
            </action>
        </xsl:variable>
        <xsl:message> actions (<xsl:value-of select="$myid"/>) = <xsl:value-of select="serialize($actions)"/>
        </xsl:message>
        <xsl:if test="not(empty($actions/action) and empty($myid))">
            <xsl:choose>
                <xsl:when test="exists(ixsl:page()//script[@id = $myid])">
                    <xsl:result-document href="#{$myid}" method="ixsl:replace-content">                                          
                        <xsl:value-of select="xml-to-json(xforms:convert-xml-to-jxml($actions))"/>                                            
                    </xsl:result-document>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:for-each select="ixsl:page()//head">                                              
                            <xsl:result-document href="?.">
                                <script type="application/json" id="{$myid}">                
                                    <xsl:value-of select="xml-to-json(xforms:convert-xml-to-jxml($actions))"/>                
                                </script>
                            </xsl:result-document>                                               
                    </xsl:for-each>
                    
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
        <xsl:choose>
            <xsl:when test="@appearance = 'minimal'">
                <a>
                    <xsl:attribute name="id" select="$myid"/>
                    <xsl:copy-of select="$innerbody"/>
                </a>
            </xsl:when>
            <xsl:otherwise>
                <button type="button">
                    <xsl:attribute name="id" select="$myid"/>
                    <!-- <xsl:copy-of select="@*[local-name() != 'ref']"/>
                    <xsl:if test="exists(@id) and map:contains($submissions,@id)">
                        <xsl:attribute name="data-action" select="map:get($submissions,@id)" />
                    </xsl:if> -->
                    <xsl:copy-of select="$innerbody"/>
                </button>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>

    <xsl:template match="xforms:insert" mode="xforms-action">
        <insert>
            <xsl:if test="exists(@ref)">
                <xsl:element name="ref">
                    <xsl:value-of select="@ref"/>
                    <xsl:value-of select="@ref"/>
                </xsl:element>
            </xsl:if>
            <xsl:if test="exists(@nodeset)">
                <xsl:element name="nodeset">
                    <xsl:value-of select="@nodeset"/>
                </xsl:element>
            </xsl:if>
            <xsl:if test="exists(@position)">
                <xsl:element name="poition">
                    <xsl:value-of select="@position"/>
                </xsl:element>
            </xsl:if>
            <xsl:if test="exists(@at)">
                <xsl:element name="at">
                    <xsl:value-of select="@at"/>
                </xsl:element>
            </xsl:if>
            <xsl:if test="exists(@if)">
                <xsl:element name="if">
                    <xsl:value-of select="@if"/>
                </xsl:element>
            </xsl:if>
            <xsl:if test="exists(@while)">
                <xsl:element name="while">
                    <xsl:value-of select="@while"/>
                </xsl:element>
            </xsl:if>
        </insert>
    </xsl:template>

    <xsl:template match="xforms:delete" mode="xforms-action">
        <delete>
            <xsl:if test="exists(@ref)">
                <xsl:element name="ref">
                    <xsl:value-of select="@ref"/>
                    <xsl:value-of select="@ref"/>
                </xsl:element>
            </xsl:if>
            <xsl:if test="exists(@nodeset)">
                <xsl:element name="nodeset">
                    <xsl:value-of select="@nodeset"/>
                </xsl:element>
            </xsl:if>
            <xsl:if test="exists(@position)">
                <xsl:element name="poition">
                    <xsl:value-of select="@position"/>
                </xsl:element>
            </xsl:if>
            <xsl:if test="exists(@at)">
                <xsl:element name="at">
                    <xsl:value-of select="@at"/>
                </xsl:element>
            </xsl:if>
            <xsl:if test="exists(@if)">
                <xsl:element name="if">
                    <xsl:value-of select="@if"/>
                </xsl:element>
            </xsl:if>
            <xsl:if test="exists(@while)">
                <xsl:element name="while">
                    <xsl:value-of select="@while"/>
                </xsl:element>
            </xsl:if>
        </delete>
    </xsl:template>

    <xsl:function name="xforms:convert-xml-to-jxml" as="node()" exclude-result-prefixes="#all">
        <xsl:param name="xinstance" as="node()"/>
        <xsl:variable name="rep-xml">
            <xsl:element name="map" namespace="http://www.w3.org/2005/xpath-functions">
                <xsl:apply-templates select="$xinstance" mode="json-xml"/>
            </xsl:element>
        </xsl:variable>
        <xsl:sequence select="$rep-xml"/>
    </xsl:function>


    <xsl:template match="*" mode="json-xml">
        <xsl:choose>
            <xsl:when test="count(*) &gt; 0">
                <xsl:for-each-group select="*" group-by="local-name()">
                    <xsl:choose>
                        <xsl:when test="count(current-group()) &gt; 1">
                            <xsl:element name="array" namespace="http://www.w3.org/2005/xpath-functions">
                                <xsl:attribute name="key" select="current-grouping-key()"/>
                                <xsl:for-each select="current-group()">
                                    <xsl:element name="map" namespace="http://www.w3.org/2005/xpath-functions">
                                        <xsl:apply-templates select="." mode="json-xml"/>
                                    </xsl:element>
                                </xsl:for-each>

                            </xsl:element>
                        </xsl:when>

                        <xsl:when test="count(current-group()/*) &gt; 0">
                            <xsl:element name="map" namespace="http://www.w3.org/2005/xpath-functions">
                                <xsl:attribute name="key" select="current-grouping-key()"/>
                                <xsl:apply-templates select="current-group()" mode="json-xml"/>
                            </xsl:element>
                        </xsl:when>
                        <xsl:otherwise>

                            <xsl:apply-templates select="current-group()" mode="json-xml"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each-group>

            </xsl:when>
            <xsl:when test=". castable as xs:int">
                <xsl:element name="number" namespace="http://www.w3.org/2005/xpath-functions">
                    <xsl:attribute name="key" select="local-name(.)"/>
                    <xsl:value-of select="./text()"/>
                </xsl:element>
            </xsl:when>
            <xsl:when test=". castable as xs:string">
                <xsl:element name="string" namespace="http://www.w3.org/2005/xpath-functions">
                    <xsl:attribute name="key" select="local-name(.)"/>
                    <xsl:value-of select="./text()"/>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise/>
        </xsl:choose>

    </xsl:template>


    <xsl:function name="xforms:convert-json-to-xml" as="node()" exclude-result-prefixes="#all">
        <xsl:param name="jinstance" as="xs:string"/>
        <xsl:variable name="rep-xml">
            <xsl:sequence select="json-to-xml($jinstance)"/>
        </xsl:variable>
        <!-- <xsl:message>TESTING json xml map = <xsl:value-of select="serialize($rep-xml)"/></xsl:message> -->
        <xsl:variable name="result">
            <!--<xsl:element name="document"> -->
            <xsl:apply-templates select="$rep-xml" mode="jxml-xml"/>
            <!--  </xsl:element> -->
        </xsl:variable>
        <xsl:sequence select="$result"/>
    </xsl:function>

    <xsl:template match="*:map" mode="jxml-xml">
        <xsl:choose>
            <xsl:when test="empty(@key)">

                <xsl:apply-templates select="*" mode="jxml-xml"/>

            </xsl:when>
            <xsl:otherwise>
                <xsl:element name="{@key}">
                    <xsl:apply-templates select="*" mode="jxml-xml"/>
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>

    <xsl:template match="*:string | *:number" mode="jxml-xml">
        <xsl:element name="{@key}">
            <xsl:value-of select="text()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="*:array" mode="jxml-xml">
        <xsl:variable name="kayVar" select="@key"/>

        <xsl:for-each select="*">
            <xsl:element name="{$kayVar}">
                <xsl:apply-templates select="." mode="jxml-xml"/>
            </xsl:element>

        </xsl:for-each>

    </xsl:template>

    <!-- Fill form using provided instance:
        must supply either $instance-xml, or $xforms-doc (to obtain default instance) -->
    <!-- Rather than updating instanceXML with data from page; update data in page from instanceXML -->
    <!-- TODO What about resetting form elements in the page which do not bind to instanceXML?? -->

    <xsl:template name="xformsjs-fill">
        <xsl:param name="instance-xml" as="document-node()?"/>
        <xsl:param name="xforms-doc" as="document-node()?" select="()"/>
        <xsl:param name="xFormsId" select="'#xForm'" as="xs:string"/>
        <xsl:param name="xforms-instance-id" select="'#xforms-jinstance'"/>

        <xsl:choose>
            <xsl:when test="empty($instance-xml) and empty($xforms-doc)">
                <xsl:sequence select="ixsl:call(ixsl:window(), 'alert',                      ['App error: must supply either $instance-xml or $xforms-doc to xformsjs-fill'])"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="instance-doc">
                    <xsl:choose>
                        <xsl:when test="empty($instance-xml)">
                            <xsl:copy-of select="$xforms-doc/xforms:xform/xforms:model/xforms:instance/*"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:copy-of select="$instance-xml"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:apply-templates select="$instance-doc" mode="form-fill-initial">
                    <xsl:with-param name="xforms-doc" select="$xforms-doc" as="document-node()?"/>
                </xsl:apply-templates>

                <!-- Update jinstance -->
                <xsl:if test="exists($instance-doc)">
                    <xsl:variable name="wrapped-instance">
                        <wrapper>
                            <xsl:sequence select="$instance-doc"/>
                        </wrapper>
                    </xsl:variable>
                    <xsl:result-document href="{$xforms-instance-id}" method="ixsl:replace-content">
                        <xsl:value-of select="xml-to-json(xforms:convert-xml-to-jxml($wrapped-instance))"/>
                    </xsl:result-document>
                </xsl:if>

                <xsl:message> xformsjs-fill instance-jxml=<xsl:value-of select="serialize(xforms:convert-json-to-xml(ixsl:page()//script[@id = 'xforms-jinstance']/text()))"/>
                </xsl:message>

            </xsl:otherwise>
        </xsl:choose>


    </xsl:template>

    <xsl:template match="*" mode="form-fill-initial">
        <xsl:param name="xforms-doc" as="document-node()?" select="()"/>
        <xsl:apply-templates select="." mode="form-fill">
            <xsl:with-param name="xforms-doc" select="$xforms-doc" as="document-node()?"/>
        </xsl:apply-templates>
    </xsl:template>

    <xsl:template match="*" mode="form-fill">
        <xsl:param name="curPath" select="''"/>
        <xsl:param name="position" select="1"/>
        <xsl:param name="xforms-doc" as="document-node()?" select="()"/>
        <!-- TODO namespaces?? -->
        <xsl:variable name="isRepeatPath" select="$xforms-doc//xforms:repeat/@nodeset=(concat($curPath, local-name()))"/>
        <xsl:if test="$isRepeatPath">
            <xsl:for-each select="ixsl:page()//div[@data-ref = concat($curPath, local-name())]/div">
                <ixsl:set-property name="style.display" select="'none'" object="."/>
            </xsl:for-each>
        </xsl:if>
        <xsl:message>isRepeatPath =  <xsl:value-of select="$isRepeatPath"/>
            updatedPath =<xsl:value-of select="concat($curPath, local-name())"/>
        </xsl:message>
        <xsl:variable name="updatedPath" select="                 if ($isRepeatPath or $position &gt; 1) then                     concat($curPath,local-name(), '[', $position, ']')                 else concat($curPath,local-name())"/>

        <xsl:message>form-fill processing node:<xsl:value-of select="local-name()"/>
        </xsl:message>
        <xsl:message>form-fill updatedPath:<xsl:value-of select="$updatedPath"/>
        </xsl:message>

        <!-- *** Process attributes of context node -->
        <xsl:apply-templates select="attribute()" mode="form-fill">
            <xsl:with-param name="curPath" select="concat($updatedPath, '/')"/>
        </xsl:apply-templates>

        <!-- *** Process text content of context node -->
        <!-- Check for associated/bound form-control with id=$updatedPath  -->
        <xsl:variable name="associated-form-control" select="ixsl:page()//*[@data-ref = $updatedPath]"/>

        <!-- TODO if position > 0, then may need to add controls first. e.g. for multiple OrderParts -->

        <xsl:choose>
            <xsl:when test="exists($associated-form-control)">
                <xsl:message>Found associated form control with id: <xsl:value-of select="$updatedPath"/>
                </xsl:message>
                <ixsl:set-property name="value" select="normalize-space(string-join(data(text()), ''))" object="$associated-form-control"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message>No associated form control with id: <xsl:value-of select="$updatedPath"/>
                </xsl:message>
            </xsl:otherwise>
        </xsl:choose>

        <!-- *** Process element children of context node -->
        <xsl:for-each-group select="element()" group-by="local-name(.)">

            <xsl:choose>
                <xsl:when test="count(current-group()) &gt; 1">
                    <xsl:message>
                        <xsl:value-of select="                                 concat(count(current-group()),                                 ' elements named ', current-grouping-key())"/>
                    </xsl:message>

                    <xsl:for-each select="current-group()">
                        <xsl:copy>
                            <xsl:apply-templates select="." mode="form-fill">
                                <xsl:with-param name="curPath" select="concat($updatedPath, '/')"/>
                                <xsl:with-param name="position" select="position()"/>
                                <xsl:with-param name="xforms-doc" select="$xforms-doc" as="document-node()?"/>
                            </xsl:apply-templates>
                        </xsl:copy>

                    </xsl:for-each>

                </xsl:when>

                <xsl:otherwise>
                    <xsl:for-each select="current-group()">
                        <xsl:copy>
                            <xsl:apply-templates select="." mode="form-fill">
                                <xsl:with-param name="curPath" select="concat($updatedPath, '/')"/>
                                <xsl:with-param name="xforms-doc" select="$xforms-doc" as="document-node()?"/>
                            </xsl:apply-templates>
                        </xsl:copy>
                    </xsl:for-each>

                </xsl:otherwise>

            </xsl:choose>

        </xsl:for-each-group>

    </xsl:template>

    <xsl:template match="@*" mode="form-fill">
        <xsl:param name="curPath" select="''"/>
        <xsl:variable name="updatedPath" select="concat($curPath, '@', local-name())"/>

        <!-- TODO what about namespaces of attributes?? -->
        <xsl:message>form-fill processing attribute node: <xsl:value-of select="local-name()"/>
        </xsl:message>
        <xsl:message>form-fill updatedPath: <xsl:value-of select="$updatedPath"/>
        </xsl:message>

        <!-- Check for associated/bound form-control with id=$updatedPath  -->
        <xsl:variable name="associated-form-control" select="ixsl:page()//*[@data-ref = $updatedPath]"/>

        <xsl:choose>
            <xsl:when test="exists($associated-form-control)">
                <xsl:message>Found associated form control with id: <xsl:value-of select="$updatedPath"/>
                </xsl:message>
                <ixsl:set-attribute name="{local-name()}" select="string(.)"/>
                <!-- TODO is this right??? -->
            </xsl:when>
            <xsl:otherwise>
                <xsl:message>No associated form control with id: <xsl:value-of select="$updatedPath"/>
                </xsl:message>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>


    <!-- Form instance check for updates made -->

    <xsl:template match="*" mode="form-check-initial">
        <xsl:copy>
            <xsl:apply-templates select="." mode="form-check"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="*" mode="form-check">
        <xsl:param name="curPath" select="''"/>
        <xsl:param name="position" select="0"/>
        <!-- TODO namespaces?? -->
        <xsl:variable name="updatedPath" select="                 if ($position &gt; 0) then                     concat($curPath, local-name(), '[', $position, ']')                 else                     concat($curPath, local-name())"/>

        <xsl:message>form-check processing node: <xsl:value-of select="local-name()"/>
        </xsl:message>
        <xsl:message>form-check updatedPath: <xsl:value-of select="$updatedPath"/>
        </xsl:message>

        <!-- *** Process attributes of context node -->
        <xsl:apply-templates select="attribute()" mode="form-check">
            <xsl:with-param name="curPath" select="concat($updatedPath, '/')"/>
        </xsl:apply-templates>

        <!-- *** Process text content of context node -->
        <!-- Check for associated/bound form-control with id=$updatedPath  -->
        <xsl:variable name="associated-form-control" select="ixsl:page()//*[@data-ref= $updatedPath]"/>

        <xsl:choose>
            <xsl:when test="exists($associated-form-control)">
                <xsl:message>Found associated form control with id: <xsl:value-of select="$updatedPath"/>
                </xsl:message>
                <xsl:value-of>
                    <xsl:apply-templates select="$associated-form-control" mode="get-field"/>
                </xsl:value-of>
            </xsl:when>
            <!--<xsl:otherwise><xsl:value-of select="."/></xsl:otherwise>-->
            <!-- Above does not just give text node content of current node -->

            <!-- TODO Is this the right way to handle white space?? -->
            <xsl:otherwise>
                <xsl:value-of select="normalize-space(string-join(data(text()), ''))"/>
            </xsl:otherwise>
        </xsl:choose>

        <!-- *** Process element children of context node -->
        <xsl:for-each-group select="element()" group-by="local-name(.)">

            <xsl:choose>
                <xsl:when test="count(current-group()) &gt; 1">
                    <xsl:message>
                        <xsl:value-of select="                                 concat(count(current-group()),                                 ' elements named ', current-grouping-key())"/>
                    </xsl:message>

                    <xsl:for-each select="current-group()">
                        <xsl:copy>
                            <xsl:apply-templates select="." mode="form-check">
                                <xsl:with-param name="curPath" select="concat($updatedPath, '/')"/>
                                <xsl:with-param name="position" select="position()"/>
                            </xsl:apply-templates>
                        </xsl:copy>

                    </xsl:for-each>

                </xsl:when>

                <xsl:otherwise>
                    <xsl:for-each select="current-group()">
                        <xsl:copy>
                            <xsl:apply-templates select="." mode="form-check">
                                <xsl:with-param name="curPath" select="concat($updatedPath, '/')"/>
                            </xsl:apply-templates>
                        </xsl:copy>
                    </xsl:for-each>

                </xsl:otherwise>

            </xsl:choose>

        </xsl:for-each-group>

    </xsl:template>

    <xsl:template match="@*" mode="form-check">
        <xsl:param name="curPath" select="''"/>
        <xsl:variable name="updatedPath" select="concat($curPath, '@', local-name())"/>

        <!-- TODO what about namespaces of attributes?? -->
        <xsl:message>form-check processing attribute node: <xsl:value-of select="local-name()"/>
        </xsl:message>
        <xsl:message>form-check updatedPath: <xsl:value-of select="$updatedPath"/>
        </xsl:message>

        <!-- Check for associated/bound form-control with id=$updatedPath  -->
        <xsl:variable name="associated-form-control" select="ixsl:page()//*[@data-ref = $updatedPath]"/>

        <xsl:choose>
            <xsl:when test="exists($associated-form-control)">
                <xsl:message>Found associated form control with id: <xsl:value-of select="$updatedPath"/>
                </xsl:message>
                <xsl:attribute name="{local-name()}">
                    <!-- TODO namespace?? -->
                    <xsl:apply-templates select="$associated-form-control" mode="get-field"/>
                </xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy select="."/>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>




    <xsl:template match="*:input" mode="get-field">

        <!-- select="ixsl:get(ixsl:page()//*[@id=$updatedPath],'value')" -->
        <xsl:sequence select="ixsl:get(., 'value')"/>
    </xsl:template>

    <xsl:template match="*:select" mode="get-field">

        <xsl:sequence select="ixsl:get(./option[ixsl:get(., 'selected') = true()], 'value')"/>
    </xsl:template>

    <xsl:template match="*:textarea" mode="get-field">

        <!-- select="ixsl:get(ixsl:page()//*[@id=$updatedPath],'value')" -->
        <xsl:sequence select="ixsl:get(., 'value')"/>
    </xsl:template>

</xsl:stylesheet>