<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet   xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
						xmlns:gml="http://www.opengis.net/gml"
						xmlns:srv="http://www.isotc211.org/2005/srv"
						xmlns:gmx="http://www.isotc211.org/2005/gmx"
						xmlns:gco="http://www.isotc211.org/2005/gco"
						xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
						xmlns:xlink="http://www.w3.org/1999/xlink"
						xmlns:mcp="http://schemas.aodn.org.au/mcp-2.0"
						xmlns:dwc="http://rs.tdwg.org/dwc/terms/"
						xmlns:gmd="http://www.isotc211.org/2005/gmd"
						exclude-result-prefixes="#all">

	<xsl:include href="../iso19139/convert/functions.xsl"/>

	<xsl:variable name="metadataStandardName" select="'Australian Marine Community Profile of ISO 19115:2005/19139'"/>
	<xsl:variable name="metadataStandardVersion" select="'2.0'"/>
  <xsl:variable name="apiSiteUrl" select="substring(/root/env/siteURL, 1, string-length(/root/env/siteURL)-4)"/>

	<xsl:variable name="mapping" select="document('mcp-equipment/equipmentToDataParamsMapping.xml')"/>

  <!-- The csv layout for each element in the above file is:
                          1)OA_EQUIPMENT_ID,
                          2)OA_EQUIPMENT_LABEL,
                          3)AODN_PLATFORM,
                          4)Platform IRI,
                          5)AODN_INSTRUMENT,
                          6)Instrument IRI,
                          7)AODN_PARAMETER,
                          8)Parameter IRI,
                          9)AODN_UNITS,
                          10)UNITS IRI
        NOTE: can be multiple rows for each equipment keyword -->

  <xsl:variable name="equipThesaurus" select="'geonetwork.thesaurus.register.equipment.urn:marlin.csiro.au:Equipment'"/>

  <xsl:variable name="idcContact" select="document('http://www.marlin.csiro.au/geonetwork/srv/eng/subtemplate?uuid=urn:marlin.csiro.au:person:125_person_organisation')"/>


	<!-- ================================================================= -->
	
	<xsl:template match="/root">
		 <xsl:apply-templates select="mcp:MD_Metadata"/>
	</xsl:template>

	<!-- ================================================================= -->
	
	<xsl:template match="mcp:MD_Metadata">
		 <xsl:copy>
		 	<xsl:copy-of select="@*[name()!='xsi:schemaLocation']"/>
			<xsl:copy-of select="/root/env/schemaLocation/@xsi:schemaLocation"/>
			<xsl:if test="not(@gco:isoType)">
				<xsl:attribute name="gco:isoType">gmd:MD_Metadata</xsl:attribute>
			</xsl:if>
		 	<xsl:choose>
				<xsl:when test="not(gmd:fileIdentifier)">
		 			<gmd:fileIdentifier>
						<gco:CharacterString><xsl:value-of select="/root/env/uuid"/></gco:CharacterString>
					</gmd:fileIdentifier>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="gmd:fileIdentifier"/>
				</xsl:otherwise>
			</xsl:choose>
      <xsl:apply-templates select="gmd:language"/>
      <xsl:apply-templates select="gmd:characterSet"/>
			<xsl:choose>
        <xsl:when test="/root/env/parentUuid!=''">
          <gmd:parentIdentifier>
            <gco:CharacterString>
              <xsl:value-of select="/root/env/parentUuid"/>
            </gco:CharacterString>
          </gmd:parentIdentifier>
        </xsl:when>
        <xsl:when test="gmd:parentIdentifier">
          <xsl:apply-templates select="gmd:parentIdentifier"/>
        </xsl:when>
      </xsl:choose>
      <xsl:apply-templates select="gmd:hierarchyLevel"/>
      <xsl:apply-templates select="gmd:hierarchyLevelName"/>
      <xsl:call-template name="addIDCContact"/>
			<xsl:choose>
				<xsl:when test="not(gmd:dateStamp) or normalize-space(gmd:dateStamp/*)=''">
					<gmd:dateStamp>
						<gco:DateTime><xsl:value-of select="/root/env/changeDate"/></gco:DateTime>
					</gmd:dateStamp>
				</xsl:when>
				<xsl:otherwise>
      		<xsl:apply-templates select="gmd:dateStamp"/>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:choose>
				<xsl:when test="not(gmd:metadataStandardName)">
					<gmd:metadataStandardName>
						<gco:CharacterString><xsl:value-of select="$metadataStandardName"/></gco:CharacterString>
					</gmd:metadataStandardName>
				</xsl:when>
				<xsl:otherwise>
      		<xsl:apply-templates select="gmd:metadataStandardName"/>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:choose>
				<xsl:when test="not(gmd:metadataStandardVersion)">
					<gmd:metadataStandardVersion>
						<gco:CharacterString><xsl:value-of select="$metadataStandardVersion"/></gco:CharacterString>
					</gmd:metadataStandardVersion>
				</xsl:when>
				<xsl:otherwise>
      		<xsl:apply-templates select="gmd:metadataStandardVersion"/>
				</xsl:otherwise>
			</xsl:choose>
      <xsl:apply-templates select="gmd:dataSetURI"/>
      <xsl:apply-templates select="gmd:locale"/>
      <xsl:apply-templates select="gmd:spatialRepresentationInfo"/>
      <xsl:apply-templates select="gmd:referenceSystemInfo"/>
      <xsl:apply-templates select="gmd:metadataExtensionInfo"/>
      <xsl:apply-templates select="gmd:identificationInfo"/>
			<xsl:apply-templates select="gmd:contentInfo"/>
			<xsl:choose>
				<xsl:when test="not(gmd:distributionInfo)">
					<gmd:distributionInfo>
						<gmd:MD_Distribution>
							<gmd:transferOptions>
								<gmd:MD_DigitalTransferOptions>
									<xsl:call-template name="addMetadataURL"/>
								</gmd:MD_DigitalTransferOptions>
							</gmd:transferOptions>
						</gmd:MD_Distribution>
					</gmd:distributionInfo>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="gmd:distributionInfo"/>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:apply-templates select="gmd:dataQualityInfo"/>
      <xsl:apply-templates select="gmd:portrayalCatalogueInfo"/>
      <xsl:apply-templates select="gmd:metadataConstraints"/>
      <xsl:apply-templates select="gmd:applicationSchemaInfo"/>
      <xsl:apply-templates select="gmd:metadataMaintenance"/>
      <xsl:apply-templates select="gmd:series"/>
      <xsl:apply-templates select="gmd:describes"/>
      <xsl:apply-templates select="gmd:propertyType"/>
      <xsl:apply-templates select="gmd:featureType"/>
      <xsl:apply-templates select="gmd:featureAttribute"/>
			<xsl:choose>
        <xsl:when test="not(mcp:revisionDate)">
          <mcp:revisionDate>
            <gco:DateTime><xsl:value-of select="/root/env/changeDate"/></gco:DateTime>
          </mcp:revisionDate>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="mcp:revisionDate"/>
        </xsl:otherwise>
      </xsl:choose>
			<xsl:choose>
        <!-- If no originator then add current user as originator -->
        <xsl:when test="/root/env/created">
          <mcp:metadataContactInfo>
            <mcp:CI_Responsibility>
              <mcp:role>
                <gmd:CI_RoleCode codeList="http://schemas.aodn.org.au/mcp-2.0/schema/resources/Codelist/gmxCodelists.xml#CI_RoleCode" codeListValue="originator">originator</gmd:CI_RoleCode>
              </mcp:role>
              <xsl:call-template name="addCurrentUserAsParty"/>
            </mcp:CI_Responsibility>
          </mcp:metadataContactInfo>
          <xsl:call-template name="addIDCAsPointOfContact"/>
        </xsl:when>
        <!-- Add current user as processor, then process everything except the 
             existing processor which will be excluded from the output
             document - this is to ensure that only the latest user is
             added as a processor - note: Marlin administrator is excluded from 
             this role -->
        <xsl:otherwise>
          <xsl:choose>
            <xsl:when test="/root/env/user/details/username!='admin'">
              <!-- marlin admin does not replace a processor -->
              <mcp:metadataContactInfo>
                <mcp:CI_Responsibility>
                  <mcp:role>
                    <gmd:CI_RoleCode codeList="http://schemas.aodn.org.au/mcp-2.0/schema/resources/Codelist/gmxCodelists.xml#CI_RoleCode" codeListValue="processor">processor</gmd:CI_RoleCode>
                  </mcp:role>
                  <xsl:call-template name="addCurrentUserAsParty"/>
                </mcp:CI_Responsibility>
              </mcp:metadataContactInfo>
              <xsl:call-template name="addIDCAsPointOfContact"/>
              <!-- copy any other metadata contacts with the exception of processors and 
                   pointOfContact so we make sure that IDC is point of contact -->
              <xsl:apply-templates select="mcp:metadataContactInfo[not(mcp:CI_Responsibility/mcp:role/gmd:CI_RoleCode='processor' or mcp:CI_Responsibility/mcp:role/gmd:CI_RoleCode='pointOfContact')]"/>
            </xsl:when>
            <xsl:otherwise>
              <!-- marlin admin does not replace a processor, so add IDC and then grab all mcp:metadataContactInfo except pointOfContact -->
              <xsl:call-template name="addIDCAsPointOfContact"/>
              <xsl:apply-templates select="mcp:metadataContactInfo[mcp:CI_Responsibility/mcp:role/gmd:CI_RoleCode!='pointOfContact']"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
		</xsl:copy>
	</xsl:template>

  <!-- ================================================================= -->

  <xsl:template name="addIDCContact">
    <xsl:variable name="org" select="$idcContact//*:name/gco:CharacterString"/>
    <xsl:element name="gmd:contact">
      <xsl:element name="gmd:CI_ResponsibleParty">
        <xsl:element name="gmd:organisationName"><gco:CharacterString><xsl:value-of select="$org"/></gco:CharacterString></xsl:element>
        <xsl:element name="gmd:positionName"><gco:CharacterString><xsl:value-of select="$idcContact//*:positionName/gco:CharacterString"/></gco:CharacterString></xsl:element>
        <xsl:element name="gmd:contactInfo">
          <xsl:element name="gmd:CI_Contact">
            <xsl:copy-of select="$idcContact//*:contactInfo/gmd:CI_Contact/gmd:address" copy-namespaces="no"/>
            <gmd:onlineResource>
              <gmd:CI_OnlineResource>
                <gmd:linkage>
                  <gmd:URL>https://research.csiro.au/oa-idc/</gmd:URL>
                </gmd:linkage>
                <gmd:protocol>
                  <gco:CharacterString>WWW:LINK-1.0-http--link</gco:CharacterString>
                </gmd:protocol>
                <gmd:name>
                  <gco:CharacterString><xsl:value-of select="concat($org,' homepage')"/></gco:CharacterString>
                </gmd:name>
                <gmd:description>
                  <gco:CharacterString><xsl:value-of select="concat('Link to ',$org,' homepage')"/></gco:CharacterString>
                </gmd:description>
              </gmd:CI_OnlineResource>
            </gmd:onlineResource>
          </xsl:element>
        </xsl:element>
        <gmd:role>
          <gmd:CI_RoleCode codeList="http://schemas.aodn.org.au/mcp-2.0/schema/resources/Codelist/gmxCodelists.xml#CI_RoleCode"
                             codeListValue="pointOfContact">pointOfContact</gmd:CI_RoleCode>
        </gmd:role>
      </xsl:element>
    </xsl:element>
  </xsl:template>

	<!-- ================================================================= -->

  <xsl:template name="addIDCAsPointOfContact">
          <mcp:metadataContactInfo>
            <mcp:CI_Responsibility>
              <mcp:role>
                <gmd:CI_RoleCode codeList="http://schemas.aodn.org.au/mcp-2.0/schema/resources/Codelist/gmxCodelists.xml#CI_RoleCode" codeListValue="pointOfContact">pointOfContact</gmd:CI_RoleCode>
              </mcp:role>
              <mcp:party xlink:href="local://xml.metadata.get?uuid=urn:marlin.csiro.au:person:125_person_organisation"/>
            </mcp:CI_Responsibility>
          </mcp:metadataContactInfo>
  </xsl:template>

	<!-- ================================================================= -->

  <xsl:template name="addCurrentUserAsParty">
              <mcp:party>
                <mcp:CI_Organisation>
                  <mcp:name>
                    <gco:CharacterString><xsl:value-of select="/root/env/user/details/organisation"/></gco:CharacterString>
                  </mcp:name>
                  <mcp:individual>
                    <mcp:CI_Individual>
                      <mcp:name>
                        <gco:CharacterString><xsl:value-of select="concat(/root/env/user/details/surname,', ',/root/env/user/details/firstname)"/></gco:CharacterString>
                      </mcp:name>
                    </mcp:CI_Individual>
                  </mcp:individual>
                </mcp:CI_Organisation>
              </mcp:party>
  </xsl:template>

	<!-- ================================================================= -->

  <xsl:template match="mcp:MD_DataIdentification" priority="100">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates select="gmd:citation"/>
      <xsl:apply-templates select="gmd:abstract"/>
      <xsl:apply-templates select="gmd:purpose"/>
      <xsl:apply-templates select="gmd:credit"/>
      <xsl:apply-templates select="gmd:status"/>
      <xsl:apply-templates select="gmd:pointOfContact"/>
      <xsl:apply-templates select="gmd:resourceMaintenance"/>
      <xsl:apply-templates select="gmd:graphicOverview"/>
      <xsl:apply-templates select="gmd:resourceFormat"/>
      <xsl:apply-templates select="gmd:descriptiveKeywords"/>
      <xsl:apply-templates select="gmd:resourceSpecificUsage"/>
      <xsl:apply-templates select="gmd:resourceConstraints"/>
      <xsl:apply-templates select="gmd:aggregationInfo"/>
      <xsl:apply-templates select="gmd:spatialRepresentationType"/>
      <xsl:apply-templates select="gmd:spatialResolution"/>
      <xsl:apply-templates select="gmd:language"/>
      <xsl:apply-templates select="gmd:characterSet"/>
      <xsl:apply-templates select="gmd:topicCategory"/>
      <xsl:apply-templates select="gmd:environmentDescription"/>
      <xsl:apply-templates select="gmd:extent"/>
      <xsl:apply-templates select="gmd:supplementalInformation"/>
      <xsl:apply-templates select="mcp:samplingFrequency"/>

      <!-- Add/Overwrite data parameters if we have an equipment keyword that matches one in our mapping -->
      <!-- if we have an equipment thesaurus with a match keyword then we process -->

      <xsl:variable name="equipPresent">
       <xsl:for-each select="//gmd:descriptiveKeywords/gmd:MD_Keywords[normalize-space(gmd:thesaurusName/gmd:CI_Citation/gmd:identifier/gmd:MD_Identifier/gmd:code/gmx:Anchor)=$equipThesaurus]/gmd:keyword/gmx:Anchor">
        <xsl:element name="dp">
          <mcp:dataParameters>
           <mcp:DP_DataParameters>
           <xsl:variable name="currentKeyword" select="text()"/>
           <!-- <xsl:message>Automatically created dp from <xsl:value-of select="$currentKeyword"/></xsl:message> -->
           <xsl:for-each select="$mapping/map/equipment">
              <xsl:variable name="tokens" select="tokenize(string(),',')"/>
              <!-- <xsl:message>Checking <xsl:value-of select="$tokens[2]"/></xsl:message> -->
              <xsl:if test="$currentKeyword=$tokens[2]">
                 <!-- <xsl:message>KW MATCHED TOKEN: <xsl:value-of select="$tokens[2]"/></xsl:message> -->
                 <xsl:call-template name="fillOutDataParameters">
 										<xsl:with-param name="tokens" select="$tokens"/> 
                 </xsl:call-template>
              </xsl:if>
           </xsl:for-each>
           </mcp:DP_DataParameters>
          </mcp:dataParameters>
        </xsl:element>
		   </xsl:for-each>
      </xsl:variable>

      <!-- Now copy the constructed data parameters into the record -->
      <xsl:for-each select="$equipPresent/dp/mcp:dataParameters[count(mcp:DP_DataParameters/*) > 0]">
      	<xsl:copy-of select="."/>
      </xsl:for-each>

			<!-- Finally, if no custodian then copy in a resource contact with
           role custodian, then the copy the other resourceContactInfo -->
      <xsl:if test="count(mcp:resourceContactInfo/mcp:CI_Responsibility/mcp:role/gmd:CI_RoleCode[@codeListValue='custodian'])=0">
        <mcp:resourceContactInfo>
            <mcp:CI_Responsibility>
               <mcp:role>
                  <gmd:CI_RoleCode codeList="http://schemas.aodn.org.au/mcp-2.0/schema/resources/Codelist/gmxCodelists.xml#CI_RoleCode"
                                   codeListValue="custodian">custodian</gmd:CI_RoleCode>
               </mcp:role>
            </mcp:CI_Responsibility>
         </mcp:resourceContactInfo>
      </xsl:if>
      <xsl:apply-templates select="mcp:resourceContactInfo"/>
   
    </xsl:copy>
  </xsl:template> 

	<!-- ================================================================= -->

  <xsl:template name="fillOutDataParameters">
    <xsl:param name="tokens"/>

    <mcp:dataParameter>
      <mcp:DP_DataParameter>
      	<mcp:parameterName>
					<mcp:DP_Term>
						<mcp:term>
							<gco:CharacterString><xsl:value-of select="$tokens[7]"/></gco:CharacterString>
						</mcp:term>
						<mcp:type>
							<mcp:DP_TypeCode codeList="http://schemas.aodn.org.au/mcp-2.0/schema/resources/Codelist/gmxCodelists.xml#DP_TypeCode" codeListValue="longName">longName</mcp:DP_TypeCode>
						</mcp:type>
						<mcp:usedInDataset>
							<gco:Boolean>false</gco:Boolean>
						</mcp:usedInDataset>
						<mcp:vocabularyTermURL>
							<gmd:URL><xsl:value-of select="$tokens[8]"/></gmd:URL>
						</mcp:vocabularyTermURL>
					</mcp:DP_Term>
			  </mcp:parameterName>
				<mcp:parameterUnits>
					<mcp:DP_Term>
						<mcp:term>
							<gco:CharacterString><xsl:value-of select="$tokens[9]"/></gco:CharacterString>
						</mcp:term>
						<mcp:type>
							<mcp:DP_TypeCode codeList="http://schemas.aodn.org.au/mcp-2.0/schema/resources/Codelist/gmxCodelists.xml#DP_TypeCode" codeListValue="longName">longName</mcp:DP_TypeCode>
						</mcp:type>
						<mcp:usedInDataset>
							<gco:Boolean>false</gco:Boolean>
						</mcp:usedInDataset>
						<mcp:vocabularyTermURL>
							<gmd:URL><xsl:value-of select="$tokens[10]"/></gmd:URL>
						</mcp:vocabularyTermURL>
					</mcp:DP_Term>
				</mcp:parameterUnits>
				<mcp:parameterMinimumValue gco:nilReason="missing">
					<gco:CharacterString/>
				</mcp:parameterMinimumValue>
				<mcp:parameterMaximumValue gco:nilReason="missing">
					<gco:CharacterString/>
				</mcp:parameterMaximumValue>
        <mcp:parameterDeterminationInstrument>
					<mcp:DP_Term>
						<mcp:term>
							<gco:CharacterString><xsl:value-of select="$tokens[5]"/></gco:CharacterString>
						</mcp:term>
						<mcp:type>
							<mcp:DP_TypeCode codeList="http://schemas.aodn.org.au/mcp-2.0/schema/resources/Codelist/gmxCodelists.xml#DP_TypeCode" codeListValue="longName">longName</mcp:DP_TypeCode>
						</mcp:type>
						<mcp:usedInDataset>
							<gco:Boolean>false</gco:Boolean>
						</mcp:usedInDataset>
						<mcp:vocabularyTermURL>
							<gmd:URL><xsl:value-of select="$tokens[6]"/></gmd:URL>
						</mcp:vocabularyTermURL>
					</mcp:DP_Term>
				</mcp:parameterDeterminationInstrument>
        <mcp:platform>
					<mcp:DP_Term>
						<mcp:term>
							<gco:CharacterString><xsl:value-of select="$tokens[3]"/></gco:CharacterString>
						</mcp:term>
						<mcp:type>
							<mcp:DP_TypeCode codeList="http://schemas.aodn.org.au/mcp-2.0/schema/resources/Codelist/gmxCodelists.xml#DP_TypeCode" codeListValue="longName">longName</mcp:DP_TypeCode>
						</mcp:type>
						<mcp:usedInDataset>
							<gco:Boolean>false</gco:Boolean>
						</mcp:usedInDataset>
						<mcp:vocabularyTermURL>
							<gmd:URL><xsl:value-of select="$tokens[4]"/></gmd:URL>
						</mcp:vocabularyTermURL>
					</mcp:DP_Term>
				</mcp:platform>
      </mcp:DP_DataParameter>
    </mcp:dataParameter>
  </xsl:template>
	
	<!-- ================================================================= -->

	<xsl:template match="gmd:MD_Distribution">
		 <xsl:copy>
		 		<xsl:copy-of select="@*"/>
      	<xsl:apply-templates select="gmd:distributionFormat"/>
      	<xsl:apply-templates select="gmd:distributor"/>
				<xsl:choose>
					<xsl:when test="not(gmd:transferOptions)">
						<gmd:transferOptions>
							<gmd:MD_DigitalTransferOptions>
								<xsl:call-template name="addMetadataURL"/>
							</gmd:MD_DigitalTransferOptions>
						</gmd:transferOptions>
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select="gmd:transferOptions"/>
					</xsl:otherwise>
				</xsl:choose>
		 </xsl:copy>
	</xsl:template>

	<!-- ================================================================= -->

  <!-- 
  <gmd:identifier xlink:title="Marlin Record Number">
    <gmd:MD_Identifier>
    <gmd:code>
      <gco:CharacterString>Marlin Record Number: 14564</gco:CharacterString>
    </gmd:code>
    ..

    Must not be copied on create/clone
  -->
  <xsl:template match="gmd:identifier[starts-with(gmd:MD_Identifier/gmd:code/gco:CharacterString,'Marlin Record Number') and /root/env/created]" priority="10000"/>

  <xsl:template match="gmd:identifier[starts-with(gmd:MD_Identifier/gmd:code/gco:CharacterString,'Anzlic Identifier') and /root/env/created]" priority="10000"/>


	<!-- ================================================================= -->
	
	<xsl:template match="gmd:fileIdentifier" priority="10">
		<xsl:copy>
			<gco:CharacterString><xsl:value-of select="/root/env/uuid"/></gco:CharacterString>
		</xsl:copy>
	</xsl:template>
	
	<!-- ================================================================= -->
	
	<xsl:template match="mcp:revisionDate" priority="10">
		<xsl:choose>
			<xsl:when test="/root/env/changeDate">
				<xsl:copy>
					<gco:DateTime><xsl:value-of select="/root/env/changeDate"/></gco:DateTime>
				</xsl:copy>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy-of select="."/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- ================================================================= -->
	
	<xsl:template match="gmd:metadataStandardName" priority="10">
		<xsl:copy>
			<gco:CharacterString><xsl:value-of select="$metadataStandardName"/></gco:CharacterString>
		</xsl:copy>
	</xsl:template>

	<!-- ================================================================= -->
	
	<xsl:template match="gmd:metadataStandardVersion" priority="10">
		<xsl:copy>
			<gco:CharacterString><xsl:value-of select="$metadataStandardVersion"/></gco:CharacterString>
		</xsl:copy>
	</xsl:template>

	<!-- ================================================================= -->

	<xsl:template match="mcp:MD_CreativeCommons" priority="10">
		<mcp:MD_Commons mcp:commonsType="Creative Commons" gco:isoType="gmd:MD_Constraints">
			<xsl:copy-of select="*"/>
		</mcp:MD_Commons>
	</xsl:template>

	<!-- ================================================================= -->

	<xsl:template match="mcp:MD_DataCommons" priority="10">
		<mcp:MD_Commons mcp:commonsType="Data Commons" gco:isoType="gmd:MD_Constraints">
			<xsl:copy-of select="*"/>
		</mcp:MD_Commons>
	</xsl:template>

	<!-- ================================================================= -->

	<xsl:template match="gmd:dateStamp">
		<xsl:choose>
			<xsl:when test="/root/env/changeDate and normalize-space(text())!=''">
				<gmd:dateStamp>
					<gco:DateTime><xsl:value-of select="/root/env/changeDate"/></gco:DateTime>
				</gmd:dateStamp>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy-of select="."/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- ================================================================= -->

	<xsl:template match="gmd:LanguageCode[@codeListValue]" priority="10">
	 	<gmd:LanguageCode codeList="http://www.loc.gov/standards/iso639-2/">
			<xsl:apply-templates select="@*[name(.)!='codeList']"/>
		</gmd:LanguageCode>
	</xsl:template>

	<!-- ================================================================= -->

	<xsl:template match="@gml:id">
		<xsl:choose>
			<xsl:when test="normalize-space(.)=''">
				<xsl:attribute name="gml:id">
					<xsl:value-of select="generate-id(.)"/>
				</xsl:attribute>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy-of select="."/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- ==================================================================== -->
	<!-- Fix srsName attribute generate CRS:84 (long/lat ordering) by default -->

	<xsl:template match="@srsName">
		<xsl:choose>
			<xsl:when test="normalize-space(.)=''">
				<xsl:attribute name="srsName">
					<xsl:text>CRS:84</xsl:text>
				</xsl:attribute>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy-of select="."/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- ================================================================= -->
	
	<xsl:template match="*[gco:CharacterString]">
		<xsl:copy>
			<xsl:apply-templates select="@*[not(name()='gco:nilReason')]"/>
			<xsl:choose>
				<xsl:when test="normalize-space(gco:CharacterString)=''">
					<xsl:attribute name="gco:nilReason">
						<xsl:choose>
							<xsl:when test="@gco:nilReason"><xsl:value-of select="@gco:nilReason"/></xsl:when>
							<xsl:otherwise>missing</xsl:otherwise>
						</xsl:choose>
					</xsl:attribute>
				</xsl:when>
				<xsl:when test="@gco:nilReason!='missing' and normalize-space(gco:CharacterString)!=''">
					<xsl:copy-of select="@gco:nilReason"/>
				</xsl:when>
			</xsl:choose>
			<xsl:apply-templates select="node()"/>
		</xsl:copy>
	</xsl:template>

	<!-- ================================================================= -->
	<!-- codelists: set @codeList path -->
	<!-- ================================================================= -->
	
	<xsl:template match="*[@codeListValue]">
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<xsl:attribute name="codeList">
				<xsl:value-of select="concat('http://schemas.aodn.org.au/mcp-2.0/schema/resources/Codelist/gmxCodelists.xml#',local-name(.))"/>
			</xsl:attribute>
			<xsl:value-of select="@codeListValue"/>
		</xsl:copy>
	</xsl:template>

	<!-- ================================================================= -->
	<!-- online resources: metadata URL -->
	<!-- ================================================================= -->

	<!-- test and see whether we need to add a metadata URL to the
			 distributionInfo -->
	     
	<xsl:template match="gmd:transferOptions[ancestor::gmd:distributionInfo and position()=1]/gmd:MD_DigitalTransferOptions">
		<xsl:copy>
		 	<xsl:copy-of select="@*"/>
			<xsl:apply-templates select="gmd:unitsOfDistribution"/>
			<xsl:apply-templates select="gmd:transferSize"/>
			<xsl:choose>
				<xsl:when test="not(gmd:onLine)">
						<xsl:call-template name="addMetadataURL"/>
				</xsl:when>
				<xsl:otherwise>
					<!-- find out whether we need to add the METADATA URL -->
					<xsl:if test="not(../..//gmd:protocol[starts-with(gco:CharacterString,'WWW:LINK-') and contains(gco:CharacterString,'metadata-URL')])">
						<xsl:call-template name="addMetadataURL"/>
					</xsl:if>
					<!-- process the onLine blocks anyway -->
					<xsl:apply-templates select="gmd:onLine"/>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:apply-templates select="gmd:offLine"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="gmd:CI_OnlineResource[starts-with(gmd:protocol/gco:CharacterString,'WWW:LINK-') and contains(gmd:protocol/gco:CharacterString,'metadata-URL') and ancestor::gmd:distributionInfo]" priority="20">
		<xsl:copy>
			<xsl:call-template name="addMetadataURLInternals"/>
		</xsl:copy>
	</xsl:template>

	<!-- ================================================================= -->
	<!-- online resources: download -->
	<!-- ================================================================= -->

	<xsl:template match="gmd:CI_OnlineResource[starts-with(gmd:protocol/gco:CharacterString,'WWW:DOWNLOAD-') and contains(gmd:protocol/gco:CharacterString,'http--download') and gmd:name]">
		<xsl:variable name="fname" select="gmd:name/gco:CharacterString|gmd:name/gmx:MimeFileType"/>
		<xsl:variable name="mimeType">
			<xsl:call-template name="getMimeTypeFile">
				<xsl:with-param name="datadir" select="/root/env/datadir"/>
				<xsl:with-param name="fname" select="$fname"/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<gmd:linkage>
				<gmd:URL>
					<xsl:choose>
						<xsl:when test="/root/env/config/downloadservice/simple='true' or contains(gmd:protocol/gco:CharacterString,'direct')">
							<xsl:value-of select="concat(/root/env/siteURL,'/resources.get?uuid=',/root/env/uuid,'&amp;fname=',$fname,'&amp;access=private')"/>
						</xsl:when>
						<xsl:when test="/root/env/config/downloadservice/withdisclaimer='true'">
							<xsl:value-of select="concat(/root/env/siteURL,'/file.disclaimer?uuid=',/root/env/uuid,'&amp;fname=',$fname,'&amp;access=private')"/>
						</xsl:when>
						<xsl:otherwise> <!-- /root/env/config/downloadservice/leave='true' -->
							<xsl:value-of select="gmd:linkage/gmd:URL"/>
						</xsl:otherwise>
					</xsl:choose>
				</gmd:URL>
			</gmd:linkage>
			<xsl:copy-of select="gmd:protocol"/>
			<xsl:copy-of select="gmd:applicationProfile"/>
			<gmd:name>
				<gmx:MimeFileType type="{$mimeType}">
					<xsl:value-of select="$fname"/>
				</gmx:MimeFileType>
			</gmd:name>
			<xsl:copy-of select="gmd:description"/>
			<xsl:copy-of select="gmd:function"/>
		</xsl:copy>
	</xsl:template>

	<!-- ================================================================= -->
	<!-- online resources: link-to-downloadable data etc -->
	<!-- ================================================================= -->

	<xsl:template match="gmd:CI_OnlineResource[starts-with(gmd:protocol/gco:CharacterString,'WWW:LINK-') and contains(gmd:protocol/gco:CharacterString,'http--download')]">
		<xsl:variable name="mimeType">
			<xsl:call-template name="getMimeTypeUrl">
				<xsl:with-param name="linkage" select="gmd:linkage/gmd:URL"/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:copy-of select="gmd:linkage"/>
			<xsl:copy-of select="gmd:protocol"/>
			<xsl:copy-of select="gmd:applicationProfile"/>
			<gmd:name>
				<gmx:MimeFileType type="{$mimeType}"/>
			</gmd:name>
			<xsl:copy-of select="gmd:description"/>
			<xsl:copy-of select="gmd:function"/>
		</xsl:copy>
	</xsl:template>

	<!-- =================================================================-->
	
	<xsl:template match="gmx:FileName">
		<xsl:copy>
			<xsl:attribute name="src">
				<xsl:value-of select="concat(/root/env/siteURL,'/resources.get?uuid=',/root/env/uuid,'&amp;fname=',.,'&amp;access=private')"/>
			</xsl:attribute>
			<xsl:value-of select="."/>
		</xsl:copy>
	</xsl:template>

	<!-- ================================================================= -->
	<!-- Set local identifier to the first 3 letters of iso code. Locale ids
		are used for multilingual charcterString using #iso2code for referencing.
	-->
	<xsl:template match="gmd:PT_Locale">
		<xsl:element name="gmd:{local-name()}">
			<xsl:variable name="id" select="upper-case(
				substring(gmd:languageCode/gmd:LanguageCode/@codeListValue, 1, 3))"/>

			<xsl:apply-templates select="@*"/>
			<xsl:if test="@id and (normalize-space(@id)='' or normalize-space(@id)!=$id)">
				<xsl:attribute name="id">
					<xsl:value-of select="$id"/>
				</xsl:attribute>
			</xsl:if>
			<xsl:apply-templates select="node()"/>
		</xsl:element>
	</xsl:template>

	<!-- Apply same changes as above to the gmd:LocalisedCharacterString -->
	<xsl:variable name="language" select="//gmd:PT_Locale" /> <!-- Need list of all locale -->
	<xsl:template  match="gmd:LocalisedCharacterString">
		<xsl:element name="gmd:{local-name()}">
			<xsl:variable name="currentLocale" select="upper-case(replace(normalize-space(@locale), '^#', ''))"/>
			<xsl:variable name="ptLocale" select="$language[upper-case(replace(normalize-space(@id), '^#', ''))=string($currentLocale)]"/>
			<xsl:variable name="id" select="upper-case(substring($ptLocale/gmd:languageCode/gmd:LanguageCode/@codeListValue, 1, 3))"/>
			<xsl:apply-templates select="@*"/>
			<xsl:if test="$id != '' and ($currentLocale='' or @locale!=concat('#', $id)) ">
				<xsl:attribute name="locale">
					<xsl:value-of select="concat('#',$id)"/>
				</xsl:attribute>
			</xsl:if>
			<xsl:apply-templates select="node()"/>
		</xsl:element>
	</xsl:template>

	<!-- ========================================================================== -->
	<!-- match gmd:pass in gmd:dataQualityInfo and set gco:nilReason="inapplicable" -->
	<!-- ========================================================================== -->
	<xsl:template match="gmd:pass[name(..)='gmd:DQ_ConformanceResult']">
    <xsl:copy>
			<xsl:attribute name="gco:nilReason">inapplicable</xsl:attribute>
    </xsl:copy>
  </xsl:template>

	<!-- ================================================================= -->
	<!-- Adjust the namespace declaration - In some cases name() is used to get the 
		element. The assumption is that the name is in the format of  <ns:element> 
		however in some cases it is in the format of <element xmlns=""> so the 
		following will convert them back to the expected value. This also corrects the issue 
		where the <element xmlns=""> loose the xmlns="" due to the exclude-result-prefixes="#all" -->
	<!-- Note: Only included prefix gml, gmd and gco for now. -->
	<!-- TODO: Figure out how to get the namespace prefix via a function so that we don't need to hard code them -->
	<!-- ================================================================= -->

	<xsl:template name="correct_ns_prefix">
		<xsl:param name="element" />
		<xsl:param name="prefix" />
		<xsl:choose>
			<xsl:when test="local-name($element)=name($element) and $prefix != '' ">
				<xsl:element name="{$prefix}:{local-name($element)}">
					<xsl:apply-templates select="@*|node()"/>
				</xsl:element>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy>
					<xsl:apply-templates select="@*|node()"/>
				</xsl:copy>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="gmd:*">
		<xsl:call-template name="correct_ns_prefix">
			<xsl:with-param name="element" select="."/>
			<xsl:with-param name="prefix" select="'gmd'"/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="gco:*">
		<xsl:call-template name="correct_ns_prefix">
			<xsl:with-param name="element" select="."/>
			<xsl:with-param name="prefix" select="'gco'"/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="gml:*">
		<xsl:call-template name="correct_ns_prefix">
			<xsl:with-param name="element" select="."/>
			<xsl:with-param name="prefix" select="'gml'"/>
		</xsl:call-template>
	</xsl:template>

	<!-- ================================================================= -->
	
	<xsl:template match="@*|node()">
		 <xsl:copy>
			  <xsl:apply-templates select="@*|node()"/>
		 </xsl:copy>
	</xsl:template>

	<!-- ================================================================= -->

	<xsl:template name="addMetadataURL">
		<gmd:onLine>
			<gmd:CI_OnlineResource>
				<xsl:call-template name="addMetadataURLInternals"/>
			</gmd:CI_OnlineResource>
		</gmd:onLine>
	</xsl:template>

	<!-- ================================================================= -->
		
	<xsl:template name="addMetadataURLInternals">
		<gmd:linkage>
			<gmd:URL>
				<!-- <xsl:value-of select="concat($apiSiteUrl,'api/records/',/root/env/uuid,'/formatters/xml')"/> Not this one as that is just the xml, we want a presentation of the xml instead -->
				<xsl:value-of select="concat(/root/env/siteURL,'catalog.search#/metadata/',/root/env/uuid)"/>
			</gmd:URL>
		</gmd:linkage>
		<gmd:protocol>
			<gco:CharacterString>WWW:LINK-1.0-http--metadata-URL</gco:CharacterString>
		</gmd:protocol>
		<gmd:description>
			<gco:CharacterString>Point of truth URL of this metadata record</gco:CharacterString>
		</gmd:description>
	</xsl:template>

</xsl:stylesheet>
