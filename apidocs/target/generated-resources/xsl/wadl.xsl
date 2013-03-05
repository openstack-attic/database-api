<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<xsl:stylesheet xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                xmlns:saxon="http://saxon.sf.net/"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:schold="http://www.ascc.net/xml/schematron"
                xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                xmlns:xhtml="http://www.w3.org/1999/xhtml"
                xmlns:wadl="http://wadl.dev.java.net/2009/02"
                xmlns:xsdxt="http://docs.rackspacecloud.com/xsd-ext/v1.0"
                version="2.0"><!--Implementers: please note that overriding process-prolog or process-root is 
    the preferred method for meta-stylesheets to use where possible. -->
<xsl:param name="archiveDirParameter"/>
   <xsl:param name="archiveNameParameter"/>
   <xsl:param name="fileNameParameter"/>
   <xsl:param name="fileDirParameter"/>
   <xsl:variable name="document-uri">
      <xsl:value-of select="document-uri(/)"/>
   </xsl:variable>

   <!--PHASES-->


<!--PROLOG-->
<xsl:template match="@*|node()" mode="#all">
      <xsl:apply-templates select="@*|node()" mode="#current"/>
   </xsl:template>

   <!--XSD TYPES FOR XSLT2-->


<!--KEYS AND FUNCTIONS-->


<!--DEFAULT RULES-->


<!--MODE: SCHEMATRON-SELECT-FULL-PATH-->
<!--This mode can be used to generate an ugly though full XPath for locators-->
<xsl:template match="*" mode="schematron-select-full-path">
      <xsl:apply-templates select="." mode="schematron-get-full-path"/>
   </xsl:template>

   <!--MODE: SCHEMATRON-FULL-PATH-->
<!--This mode can be used to generate an ugly though full XPath for locators-->
<xsl:template match="*" mode="schematron-get-full-path">
      <xsl:apply-templates select="parent::*" mode="schematron-get-full-path"/>
      <xsl:text>/</xsl:text>
      <xsl:choose>
         <xsl:when test="namespace-uri()=''">
            <xsl:value-of select="name()"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>*:</xsl:text>
            <xsl:value-of select="local-name()"/>
            <xsl:text>[namespace-uri()='</xsl:text>
            <xsl:value-of select="namespace-uri()"/>
            <xsl:text>']</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:variable name="preceding"
                    select="count(preceding-sibling::*[local-name()=local-name(current())                                   and namespace-uri() = namespace-uri(current())])"/>
      <xsl:text>[</xsl:text>
      <xsl:value-of select="1+ $preceding"/>
      <xsl:text>]</xsl:text>
   </xsl:template>
   <xsl:template match="@*" mode="schematron-get-full-path">
      <xsl:apply-templates select="parent::*" mode="schematron-get-full-path"/>
      <xsl:text>/</xsl:text>
      <xsl:choose>
         <xsl:when test="namespace-uri()=''">@<xsl:value-of select="name()"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>@*[local-name()='</xsl:text>
            <xsl:value-of select="local-name()"/>
            <xsl:text>' and namespace-uri()='</xsl:text>
            <xsl:value-of select="namespace-uri()"/>
            <xsl:text>']</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <!--MODE: SCHEMATRON-FULL-PATH-2-->
<!--This mode can be used to generate prefixed XPath for humans-->
<xsl:template match="node() | @*" mode="schematron-get-full-path-2">
      <xsl:for-each select="ancestor-or-self::*">
         <xsl:text>/</xsl:text>
         <xsl:value-of select="name(.)"/>
         <xsl:if test="preceding-sibling::*[name(.)=name(current())]">
            <xsl:text>[</xsl:text>
            <xsl:value-of select="count(preceding-sibling::*[name(.)=name(current())])+1"/>
            <xsl:text>]</xsl:text>
         </xsl:if>
      </xsl:for-each>
      <xsl:if test="not(self::*)">
         <xsl:text/>/@<xsl:value-of select="name(.)"/>
      </xsl:if>
   </xsl:template>
   <!--MODE: SCHEMATRON-FULL-PATH-3-->
<!--This mode can be used to generate prefixed XPath for humans 
	(Top-level element has index)-->
<xsl:template match="node() | @*" mode="schematron-get-full-path-3">
      <xsl:for-each select="ancestor-or-self::*">
         <xsl:text>/</xsl:text>
         <xsl:value-of select="name(.)"/>
         <xsl:if test="parent::*">
            <xsl:text>[</xsl:text>
            <xsl:value-of select="count(preceding-sibling::*[name(.)=name(current())])+1"/>
            <xsl:text>]</xsl:text>
         </xsl:if>
      </xsl:for-each>
      <xsl:if test="not(self::*)">
         <xsl:text/>/@<xsl:value-of select="name(.)"/>
      </xsl:if>
   </xsl:template>

   <!--MODE: GENERATE-ID-FROM-PATH -->
<xsl:template match="/" mode="generate-id-from-path"/>
   <xsl:template match="text()" mode="generate-id-from-path">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:value-of select="concat('.text-', 1+count(preceding-sibling::text()), '-')"/>
   </xsl:template>
   <xsl:template match="comment()" mode="generate-id-from-path">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:value-of select="concat('.comment-', 1+count(preceding-sibling::comment()), '-')"/>
   </xsl:template>
   <xsl:template match="processing-instruction()" mode="generate-id-from-path">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:value-of select="concat('.processing-instruction-', 1+count(preceding-sibling::processing-instruction()), '-')"/>
   </xsl:template>
   <xsl:template match="@*" mode="generate-id-from-path">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:value-of select="concat('.@', name())"/>
   </xsl:template>
   <xsl:template match="*" mode="generate-id-from-path" priority="-0.5">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:text>.</xsl:text>
      <xsl:value-of select="concat('.',name(),'-',1+count(preceding-sibling::*[name()=name(current())]),'-')"/>
   </xsl:template>

   <!--MODE: GENERATE-ID-2 -->
<xsl:template match="/" mode="generate-id-2">U</xsl:template>
   <xsl:template match="*" mode="generate-id-2" priority="2">
      <xsl:text>U</xsl:text>
      <xsl:number level="multiple" count="*"/>
   </xsl:template>
   <xsl:template match="node()" mode="generate-id-2">
      <xsl:text>U.</xsl:text>
      <xsl:number level="multiple" count="*"/>
      <xsl:text>n</xsl:text>
      <xsl:number count="node()"/>
   </xsl:template>
   <xsl:template match="@*" mode="generate-id-2">
      <xsl:text>U.</xsl:text>
      <xsl:number level="multiple" count="*"/>
      <xsl:text>_</xsl:text>
      <xsl:value-of select="string-length(local-name(.))"/>
      <xsl:text>_</xsl:text>
      <xsl:value-of select="translate(name(),':','.')"/>
   </xsl:template>
   <!--Strip characters--><xsl:template match="text()" priority="-1"/>

   <!--SCHEMA SETUP-->
<xsl:template match="/">
      <svrl:schematron-output xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                              title="WADL Assertions"
                              schemaVersion="">
         <xsl:comment>
            <xsl:value-of select="$archiveDirParameter"/>   
		 <xsl:value-of select="$archiveNameParameter"/>  
		 <xsl:value-of select="$fileNameParameter"/>  
		 <xsl:value-of select="$fileDirParameter"/>
         </xsl:comment>
         <svrl:ns-prefix-in-attribute-values uri="http://wadl.dev.java.net/2009/02" prefix="wadl"/>
         <svrl:ns-prefix-in-attribute-values uri="http://www.w3.org/2001/XMLSchema" prefix="xsd"/>
         <svrl:ns-prefix-in-attribute-values uri="http://docs.rackspacecloud.com/xsd-ext/v1.0" prefix="xsdxt"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">References</xsl:attribute>
            <xsl:attribute name="name">References</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M4"/>
      </svrl:schematron-output>
   </xsl:template>

   <!--SCHEMATRON PATTERNS-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">WADL Assertions</svrl:text>

   <!--PATTERN References-->


	<!--RULE -->
<xsl:template match="wadl:resource/@type" priority="1008" mode="M4">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="wadl:resource/@type"/>
      <xsl:variable name="baseDocURI"
                    select="string-join(tokenize(base-uri(..),'/')[position() ne last()], '/')"/>
      <xsl:variable name="ids" select="tokenize(normalize-space(.),' ')"/>
      <xsl:variable name="remoteids"
                    select="                 for                      $refs in $ids[not(substring-before(.,'#') = '')]                 return                         $refs                 "/>
      <xsl:variable name="localids"
                    select="                 for                  $refs in $ids[substring-before(.,'#') = '']                 return                         $refs                 "/>
      <xsl:variable name="localAttRef"
                    select="every $id in $localids satisfies (//@id[. = substring-after($id,'#')])"/>
      <xsl:variable name="remoteAttRef"
                    select="every $id in $remoteids satisfies (document(resolve-uri(substring-before($id,'#'),concat($baseDocURI,'/')))/wadl:application//@id[.= substring-after($id,'#')])"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="every $ref in $ids satisfies contains($ref, '#')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="every $ref in $ids satisfies contains($ref, '#')">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                In the set of references '<xsl:text/>
                  <xsl:value-of select="."/>
                  <xsl:text/>', the following references '<xsl:text/>
                  <xsl:value-of select="$ids[not(contains(.,'#'))]"/>
                  <xsl:text/>' are missing '#'.
            </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="$remoteAttRef"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$remoteAttRef">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                In the set of refereces '<xsl:text/>
                  <xsl:value-of select="."/>
                  <xsl:text/>', the following external references '<xsl:text/>
                  <xsl:value-of select="for $id in $remoteids return if (not(document(resolve-uri(substring-before($id,'#'),concat($baseDocURI,'/')))/wadl:application//@id[.= substring-after($id,'#')])) then $id else ()"/>
                  <xsl:text/>' do not seem to exist.
            </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="$localAttRef"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$localAttRef">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                In the set of references '<xsl:text/>
                  <xsl:value-of select="."/>
                  <xsl:text/>', the following references '<xsl:text/>
                  <xsl:value-of select="for $id in $localids return if (not(//@id[. = substring-after($id,'#')])) then $id else ()"/>
                  <xsl:text/>' do not seem to exist in this wadl.
            </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="every $id in $localids satisfies (//@id[(. = substring-after($id,'#')) and (local-name(..)='resource_type')])"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="every $id in $localids satisfies (//@id[(. = substring-after($id,'#')) and (local-name(..)='resource_type')])">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                In the set of references '<xsl:text/>
                  <xsl:value-of select="."/>
                  <xsl:text/>', the following references '<xsl:text/>
                  <xsl:value-of select="for $id in $localids return if (//@id[(. = substring-after($id,'#')) and (local-name(..)='resource_type')]) then () else $id"/>
                  <xsl:text/>' are not pointing to a resource type.
            </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="every $id in $remoteids satisfies (document(resolve-uri(substring-before($id,'#'),concat($baseDocURI,'/')))/wadl:application//@id[.= substring-after($id,'#') and (local-name(..)='resource_type')])"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="every $id in $remoteids satisfies (document(resolve-uri(substring-before($id,'#'),concat($baseDocURI,'/')))/wadl:application//@id[.= substring-after($id,'#') and (local-name(..)='resource_type')])">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                In the set of references '<xsl:text/>
                  <xsl:value-of select="."/>
                  <xsl:text/>', the following external references '<xsl:text/>
                  <xsl:value-of select="for $id in $remoteids return if (document(resolve-uri(substring-before($id,'#'),concat($baseDocURI,'/')))/wadl:application//@id[.= substring-after($id,'#') and (local-name(..)='resource_type')]) then () else $id"/>
                  <xsl:text/>' are not pointing to a resource type.
            </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M4"/>
   </xsl:template>

	  <!--RULE -->
<xsl:template match="wadl:link/@resource_type" priority="1007" mode="M4">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="wadl:link/@resource_type"/>
      <xsl:variable name="doc" select="substring-before(.,'#')"/>
      <xsl:variable name="ref" select="substring-after(.,'#')"/>
      <xsl:variable name="baseDocURI"
                    select="string-join(tokenize(base-uri(..),'/')[position() ne last()], '/')"/>
      <xsl:variable name="attRef"
                    select="if (string-length($doc) != 0) then document(resolve-uri($doc,concat($baseDocURI,'/')))/wadl:application//@id[.=$ref] else //@id[.=$ref]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="contains(., '#')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="contains(., '#')">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                The reference '<xsl:text/>
                  <xsl:value-of select="."/>
                  <xsl:text/>' is missing '#'.
            </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="$attRef"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$attRef">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                The reference '<xsl:text/>
                  <xsl:value-of select="."/>
                  <xsl:text/>' does not seem to exist.
            </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="local-name($attRef/..)='resource_type'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="local-name($attRef/..)='resource_type'">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                The reference '<xsl:text/>
                  <xsl:value-of select="."/>
                  <xsl:text/>' should point to a resource_type.
            </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M4"/>
   </xsl:template>

	  <!--RULE -->
<xsl:template match="wadl:method/@href" priority="1006" mode="M4">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="wadl:method/@href"/>
      <xsl:variable name="doc" select="substring-before(.,'#')"/>
      <xsl:variable name="ref" select="substring-after(.,'#')"/>
      <xsl:variable name="baseDocURI"
                    select="string-join(tokenize(base-uri(..),'/')[position() ne last()], '/')"/>
      <xsl:variable name="attRef"
                    select="if (string-length($doc) != 0) then document(resolve-uri($doc,concat($baseDocURI,'/')))/wadl:application//@id[.=$ref] else //@id[.=$ref]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="contains(., '#')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="contains(., '#')">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                The reference '<xsl:text/>
                  <xsl:value-of select="."/>
                  <xsl:text/>' is missing '#'.
            </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="$attRef"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$attRef">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                The reference '<xsl:text/>
                  <xsl:value-of select="."/>
                  <xsl:text/>' does not seem to exist.
            </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="local-name($attRef/..)='method'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="local-name($attRef/..)='method'">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                The reference '<xsl:text/>
                  <xsl:value-of select="."/>
                  <xsl:text/>' should point to a method.
            </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M4"/>
   </xsl:template>

	  <!--RULE -->
<xsl:template match="wadl:representation/@href" priority="1005" mode="M4">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="wadl:representation/@href"/>
      <xsl:variable name="doc" select="substring-before(.,'#')"/>
      <xsl:variable name="ref" select="substring-after(.,'#')"/>
      <xsl:variable name="baseDocURI"
                    select="string-join(tokenize(base-uri(..),'/')[position() ne last()], '/')"/>
      <xsl:variable name="attRef"
                    select="if (string-length($doc) != 0) then document(resolve-uri($doc,concat($baseDocURI,'/')))/wadl:application//@id[.=$ref] else //@id[.=$ref]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="contains(., '#')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="contains(., '#')">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                The reference '<xsl:text/>
                  <xsl:value-of select="."/>
                  <xsl:text/>' is missing '#'.
            </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="$attRef"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$attRef">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                The reference '<xsl:text/>
                  <xsl:value-of select="."/>
                  <xsl:text/>' does not seem to exist.
            </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="local-name($attRef/..)='representation'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="local-name($attRef/..)='representation'">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                The reference '<xsl:text/>
                  <xsl:value-of select="."/>
                  <xsl:text/>' should point to a representation.
            </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M4"/>
   </xsl:template>

	  <!--RULE -->
<xsl:template match="wadl:param/@href" priority="1004" mode="M4">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="wadl:param/@href"/>
      <xsl:variable name="doc" select="substring-before(.,'#')"/>
      <xsl:variable name="ref" select="substring-after(.,'#')"/>
      <xsl:variable name="baseDocURI"
                    select="string-join(tokenize(base-uri(..),'/')[position() ne last()], '/')"/>
      <xsl:variable name="attRef"
                    select="if (string-length($doc) != 0) then document(resolve-uri($doc,concat($baseDocURI,'/')))/wadl:application//@id[.=$ref] else //@id[.=$ref]"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="contains(., '#')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="contains(., '#')">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                The reference '<xsl:text/>
                  <xsl:value-of select="."/>
                  <xsl:text/>' is missing '#'.
            </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="$attRef"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$attRef">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                The reference '<xsl:text/>
                  <xsl:value-of select="."/>
                  <xsl:text/>' does not seem to exist.
            </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="local-name($attRef/..)='param'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="local-name($attRef/..)='param'">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                The reference '<xsl:text/>
                  <xsl:value-of select="."/>
                  <xsl:text/>' point to a param.
            </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M4"/>
   </xsl:template>

	  <!--RULE -->
<xsl:template match="wadl:include/@href" priority="1003" mode="M4">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="wadl:include/@href"/>
      <xsl:variable name="baseDocURI"
                    select="string-join(tokenize(base-uri(..),'/')[position() ne last()], '/')"/>
      <xsl:variable name="refURI" select="resolve-uri(.,base-uri(..))"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="unparsed-text-available($refURI) or doc-available($refURI)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="unparsed-text-available($refURI) or doc-available($refURI)">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                The reference '<xsl:text/>
                  <xsl:value-of select="."/>
                  <xsl:text/>' does not seem to exist.
            </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M4"/>
   </xsl:template>

	  <!--RULE -->
<xsl:template match="xsd:schema/xsd:import/@schemaLocation"
                 priority="1002"
                 mode="M4">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="xsd:schema/xsd:import/@schemaLocation"/>
      <xsl:variable name="baseDocURI"
                    select="string-join(tokenize(base-uri(..),'/')[position() ne last()], '/')"/>
      <xsl:variable name="refURI" select="resolve-uri(.,base-uri(..))"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="doc-available($refURI)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="doc-available($refURI)">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                The reference '<xsl:text/>
                  <xsl:value-of select="."/>
                  <xsl:text/>' does not seem to exist.
            </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="document($refURI)/xsd:schema"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="document($refURI)/xsd:schema">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                The reference '<xsl:text/>
                  <xsl:value-of select="."/>
                  <xsl:text/>' does not appear to be a valid XSD schema.
            </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M4"/>
   </xsl:template>

	  <!--RULE -->
<xsl:template match="xsd:schema/xsd:include/@schemaLocation"
                 priority="1001"
                 mode="M4">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="xsd:schema/xsd:include/@schemaLocation"/>
      <xsl:variable name="baseDocURI"
                    select="string-join(tokenize(base-uri(..),'/')[position() ne last()], '/')"/>
      <xsl:variable name="refURI" select="resolve-uri(.,base-uri(..))"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="doc-available($refURI)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="doc-available($refURI)">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                The reference '<xsl:text/>
                  <xsl:value-of select="."/>
                  <xsl:text/>' does not seem to exist.
            </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="document($refURI)/xsd:schema"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="document($refURI)/xsd:schema">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                The reference '<xsl:text/>
                  <xsl:value-of select="."/>
                  <xsl:text/>' does not appear to be a valid XSD schema.
            </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M4"/>
   </xsl:template>

	  <!--RULE -->
<xsl:template match="xsdxt:code/@href" priority="1000" mode="M4">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="xsdxt:code/@href"/>
      <xsl:variable name="baseDocURI"
                    select="string-join(tokenize(base-uri(..),'/')[position() ne last()], '/')"/>
      <xsl:variable name="refURI" select="resolve-uri(.,base-uri(..))"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="unparsed-text-available($refURI) or doc-available($refURI)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="unparsed-text-available($refURI) or doc-available($refURI)">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                The reference '<xsl:text/>
                  <xsl:value-of select="."/>
                  <xsl:text/>' does not seem to exist.
            </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M4"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M4"/>
   <xsl:template match="@*|node()" priority="-2" mode="M4">
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M4"/>
   </xsl:template>
</xsl:stylesheet>
