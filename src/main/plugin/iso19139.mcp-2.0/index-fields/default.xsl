<?xml version="1.0" encoding="UTF-8" ?>

<xsl:stylesheet version="2.0" xmlns:gmd="http://www.isotc211.org/2005/gmd"
			xmlns:gmx="http://www.isotc211.org/2005/gmx"
			xmlns:gco="http://www.isotc211.org/2005/gco"
			xmlns:gml="http://www.opengis.net/gml"
			xmlns:srv="http://www.isotc211.org/2005/srv"
			xmlns:geonet="http://www.fao.org/geonetwork"
			xmlns:mcp="http://schemas.aodn.org.au/mcp-2.0"
			xmlns:xlink="http://www.w3.org/1999/xlink"
			xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
			exclude-result-prefixes="gmd gmx gco gml srv geonet mcp xlink xsl">


	<xsl:import href="../../iso19139/index-fields/default.xsl"/>

	<xsl:include href="../../iso19139/convert/functions.xsl"/>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -     
       This template matches 
       mcp:MD_DataIdentification/gmd:citation/mcp:CI_Citation - 
       gmd:CI_Citation is handled in ../iso19139/index-fields.xsl. 
       Note: we don't match any other mcp:CI_Citation blocks as this 
       template extracts the citation details of the resource.
       - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template mode="index" match="mcp:MD_DataIdentification/gmd:citation/mcp:CI_Citation">

    <xsl:for-each select="gmd:identifier/gmd:MD_Identifier/gmd:code/gco:CharacterString">
      <Field name="identifier" string="{string(.)}" store="true" index="true"/>
    </xsl:for-each>

    <xsl:for-each select="gmd:title/gco:CharacterString">
      <Field name="title" string="{string(.)}" store="true" index="true"/>
      <!-- not tokenized title for sorting -->
      <Field name="_title" string="{string(.)}" store="true" index="true"/>
    </xsl:for-each>

    <xsl:for-each select="gmd:alternateTitle/gco:CharacterString">
      <Field name="altTitle" string="{string(.)}" store="true" index="true"/>
    </xsl:for-each>

    <xsl:for-each select="gmd:date/gmd:CI_Date[gmd:dateType/gmd:CI_DateTypeCode/@codeListValue='revision']/gmd:date/gco:Date|gmd:date/gmd:CI_Date[gmd:dateType/gmd:CI_DateTypeCode/@codeListValue='revision']/gmd:date/gco:DateTime">
      <Field name="revisionDate" string="{string(.)}" store="true" index="true"/>
    </xsl:for-each>

    <xsl:for-each select="gmd:date/gmd:CI_Date[gmd:dateType/gmd:CI_DateTypeCode/@codeListValue='creation']/gmd:date/gco:Date|gmd:date/gmd:CI_Date[gmd:dateType/gmd:CI_DateTypeCode/@codeListValue='creation']/gmd:date/gco:DateTime">
      <Field name="createDate" string="{string(.)}" store="true" index="true"/>
    </xsl:for-each>

    <xsl:for-each select="gmd:date/gmd:CI_Date[gmd:dateType/gmd:CI_DateTypeCode/@codeListValue='publication']/gmd:date/gco:Date">
      <Field name="publicationDate" string="{string(.)}" store="true" index="true"/>
    </xsl:for-each>

    <xsl:apply-templates mode="index" select="*"/>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -     
       If an online resource contains a protocol field with csiro in it 
       then make sure that this record has download indexed so that 
       quick search on data attached can be used
       - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  <xsl:template mode="index" match="gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine/gmd:CI_OnlineResource[gmd:linkage/gmd:URL!='' and (contains(gmd:protocol/*,'http--csiro-oa-app') or contains(gmd:protocol/*,'download'))]">
    <Field name="download" string="on" store="false" index="true"/>
  </xsl:template>

	<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->		

	<xsl:template mode="index" match="mcp:dataParameters/mcp:DP_DataParameters/mcp:dataParameter">
		<xsl:for-each select="mcp:DP_DataParameter/mcp:parameterName/mcp:DP_Term">
			<xsl:variable name="term" select="mcp:term/*"/>
			<Field name="dataparam" string="{$term}" store="true" index="true"/>
			<xsl:if test="mcp:type/mcp:DP_TypeCode/@codeListValue='longName'">
				<Field name="longParamName" string="{$term}" store="true" index="true"/>
			</xsl:if>
			<xsl:for-each select="mcp:vocabularyRelationship/mcp:DP_VocabularyRelationship">
				<Field name="vocabTerm" string="{mcp:vocabularyTermURL/gmd:URL}" store="true" index="true"/>
				<Field name="vocabTermList" string="{mcp:vocabularyListURL/gmd:URL}" store="true" index="true"/>
			</xsl:for-each>
		</xsl:for-each>

		<xsl:apply-templates mode="index" select="*"/>
	</xsl:template>

	<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->		

  <xsl:template mode="index" match="mcp:EX_Extent">

    <xsl:apply-templates select="gmd:geographicElement/gmd:EX_GeographicBoundingBox" mode="latLon"/>

    <xsl:for-each select="gmd:geographicElement/gmd:EX_GeographicDescription/gmd:geographicIdentifier/gmd:MD_Identifier/gmd:code/gco:CharacterString">
      <Field name="geoDescCode" string="{string(.)}" store="true" index="true"/>
    </xsl:for-each>

    <xsl:for-each select="gmd:geographicElement/gmd:EX_GeographicDescription/gmd:geographicIdentifier/gmd:RS_Identifier">
      <xsl:if test="gmd:authority/*/gmd:title/gco:CharacterString='c-squares'">
        <xsl:for-each select="tokenize(gmd:code/gco:CharacterString,'\|')">
          <Field name="csquare" string="{string(.)}" store="false" index="true"/>
        </xsl:for-each>
      </xsl:if>
    </xsl:for-each>

    <xsl:for-each select="gmd:temporalElement/mcp:EX_TemporalExtent/gmd:extent|gmd:temporalElement/gmd:EX_TemporalExtent/gmd:extent">
      <xsl:for-each select="gml:TimePeriod">
        <xsl:variable name="times">
          <xsl:call-template name="newGmlTime">
            <xsl:with-param name="begin" select="gml:beginPosition|gml:begin/gml:TimeInstant/gml:timePosition"/>
            <xsl:with-param name="end" select="gml:endPosition|gml:end/gml:TimeInstant/gml:timePosition"/>
          </xsl:call-template>
        </xsl:variable>

        <Field name="tempExtentBegin" string="{lower-case(substring-before($times,'|'))}" store="true" index="true"/>
        <Field name="tempExtentEnd" string="{lower-case(substring-after($times,'|'))}" store="true" index="true"/>
      </xsl:for-each>
    </xsl:for-each>

    <xsl:apply-templates mode="index" select="*"/>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template mode="index" match="mcp:resourceContactInfo">
    <xsl:apply-templates mode="index-mcp-contact" select="mcp:CI_Responsibility">
      <xsl:with-param name="type" select="'resource'"/>
      <xsl:with-param name="fieldPrefix" select="'responsibleParty'"/>     
      <xsl:with-param name="position" select="count(preceding-sibling::*)"/>
    </xsl:apply-templates>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

  <xsl:template mode="index" match="mcp:metadataContactInfo">
    <xsl:apply-templates mode="index-mcp-contact" select="mcp:CI_Responsibility">
      <xsl:with-param name="type" select="'metadata'"/>
      <xsl:with-param name="fieldPrefix" select="'responsibleParty'"/>     
      <xsl:with-param name="position" select="count(preceding-sibling::*)"/>
    </xsl:apply-templates>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

	<xsl:template mode="index" match="mcp:revisionDate/*">

		<Field name="changeDate" string="{string(.)}" store="true" index="true"/>

		<xsl:apply-templates mode="index" select="*"/>
	</xsl:template>
		
	<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
		
	<xsl:template mode="index" match="gmd:MD_Keywords">

		<xsl:variable name="thesaurusId" select="normalize-space(gmd:thesaurusName/*/gmd:identifier/*/gmd:code[starts-with(string(gmx:Anchor),'geonetwork.thesaurus')])"/>

		<xsl:if test="$thesaurusId!=''">
			<Field name="thesaurusName" string="{string($thesaurusId)}" store="true" index="true"/>
		</xsl:if>

		<!-- index keyword codes under lucene index field with name same
				 as thesaurus that contains the keyword codes -->

		<xsl:for-each select="gmd:keyword/*">
			<xsl:if test="name()='gmx:Anchor' and $thesaurusId!=''">
				<!-- expecting something like 
							    	<gmx:Anchor 
									  	xlink:href="http://localhost:8080/geonetwork/srv/en/xml.keyword.get?thesaurus=register.theme.urn:marine.csiro.au:marlin:keywords:standardDataType&id=urn:marine.csiro.au:marlin:keywords:standardDataTypes:concept:3510">CMAR Vessel Data: ADCP</gmx:Anchor>
				-->
	
				<xsl:variable name="keywordId">
					<xsl:for-each select="tokenize(@xlink:href,'&amp;')">
						<xsl:if test="starts-with(string(.),'id=')">
							<xsl:value-of select="substring-after(string(.),'id=')"/>
						</xsl:if>
					</xsl:for-each>
				</xsl:variable>
	
				<xsl:if test="normalize-space($keywordId)!=''">
					<Field name="{$thesaurusId}" string="{replace($keywordId,'%23','#')}" store="true" index="true"/>
          <Field name="keywordId" string="{replace($keywordId,'%23','#')}" store="true" index="true"/>
				</xsl:if>
			</xsl:if>

      <xsl:choose>
            <xsl:when test="contains($thesaurusId,'sourceregister')">
              <Field name="source" string="{string(.)}" store="true" index="true"/>
            </xsl:when>
            <xsl:when test="contains($thesaurusId,'surveyregister')">
              <Field name="survey" string="{string(.)}" store="true" index="true"/>
            </xsl:when>
            <xsl:when test="contains($thesaurusId,'projectregister')">
              <Field name="project" string="{string(.)}" store="true" index="true"/>
            </xsl:when>
            <xsl:when test="contains($thesaurusId,'gcmd_keywords')">
              <Field name="gcmd" string="{string(.)}" store="true" index="true"/>
            </xsl:when>
            <xsl:when test="contains($thesaurusId,'awavea-keywords')">
              <Field name="awavea" string="{string(.)}" store="true" index="true"/>
            </xsl:when>
            <xsl:otherwise>
              <Field name="otherkeyword" string="{string(.)}" store="true" index="true"/>
            </xsl:otherwise>
      </xsl:choose>
		</xsl:for-each>

		<xsl:apply-templates mode="index" select="*"/>
	</xsl:template>
	
	<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -     
	     If aggregation code comes from a thesaurus then index it and the      
	     the thesaurus it comes from in this template                          
	     - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
	<xsl:template mode="index" match="gmd:aggregationInfo/*">

		<xsl:variable name="code" select="string(gmd:aggregateDataSetIdentifier/*/gmd:code/*)"/>

		<xsl:variable name="thesaurusId" select="gmd:aggregateDataSetIdentifier/*/gmd:authority/*/gmd:identifier/*/gmd:code/gmx:Anchor"/>
		<xsl:if test="contains($thesaurusId,'geonetwork.thesaurus') and normalize-space($code)!=''">
			<Field name="thesaurusName" string="{$thesaurusId}" store="true" index="true"/>
			<!-- thesaurusId field not used for searching -->
			<Field name="{$thesaurusId}" string="{$code}" store="true" index="true"/>
			<xsl:variable name="initiative" select="gmd:initiativeType/gmd:DS_InitiativeTypeCode/@codeListValue"/>
			<!-- initiative field is used for searching -->
			<xsl:if test="normalize-space($initiative)!=''">
				<Field name="{concat('siblings_',$initiative)}" string="{$code}" store="true" index="true"/>
			</xsl:if>
		</xsl:if>

		<xsl:apply-templates mode="index" select="*"/>
	</xsl:template>

	<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->		

  <xsl:template mode="index-mcp-contact" match="mcp:CI_Responsibility">
    <xsl:param name="type"/>
    <xsl:param name="fieldPrefix"/>
    <xsl:param name="position" select="'0'"/>

      <xsl:variable name="orgName" select="mcp:party/mcp:CI_Organisation/mcp:name/gco:CharacterString"/>

      <Field name="orgName" string="{$orgName}" store="true" index="true"/>
      <Field name="orgNameTree" string="{$orgName}" store="true" index="true"/>

      <xsl:variable name="role" select="mcp:role/*/@codeListValue"/>
      <xsl:variable name="logo" select="''"/>
      <xsl:variable name="uuid" select="''"/>
      <xsl:variable name="email" select="mcp:party/mcp:CI_Organisation/mcp:contactInfo/*/gmd:address/*/gmd:electronicMailAddress/gco:CharacterString"/>
      <xsl:variable name="phone"
                  select="mcp:party/mcp:CI_Organisation/mcp:contactInfo/*/gmd:phone/*/gmd:voice[normalize-space(.) != '']/*/text()"/>
      <xsl:variable name="individualName"
                  select="mcp:party/mcp:CI_Organisation/mcp:individual/mcp:CI_Individual/mcp:name/gco:CharacterString/text()"/>
      <xsl:variable name="positionName"
                  select="mcp:party/mcp:CI_Organisation/mcp:individual/mcp:CI_Individual/mcp:positionName/gco:CharacterString/text()"/>
      <xsl:variable name="address" select="string-join(mcp:party/mcp:CI_Organisation/mcp:contactInfo/*/gmd:address/*/(gmd:deliveryPoint|gmd:postalCode|gmd:city|gmd:administrativeArea|gmd:country)/gco:CharacterString/text(), ', ')"/>

      <Field name="{$fieldPrefix}"
             string="{concat($role, '|', $type ,'|',
                             $orgName, '|',
                             $logo, '|',
                             string-join($email, ','), '|',
                             $individualName, '|',
                             $positionName, '|',
                             $address, '|',
                             string-join($phone, ','), '|',
                             $uuid, '|',
                             $position)}"
             store="true" index="false"/>

      <xsl:for-each select="$email">
        <Field name="{$fieldPrefix}Email" string="{string(.)}" store="true" index="true"/>
        <Field name="{$fieldPrefix}RoleAndEmail" string="{$role}|{string(.)}" store="true" index="true"/>
      </xsl:for-each>
      <xsl:for-each select="@uuid">
        <Field name="{$fieldPrefix}Uuid" string="{string(.)}" store="true" index="true"/>
        <Field name="{$fieldPrefix}RoleAndUuid" string="{$role}|{string(.)}" store="true" index="true"/>
      </xsl:for-each>
  </xsl:template>
</xsl:stylesheet>
