<?xml version="1.0" encoding="UTF-8"?>
<!--
  ~ Copyright (C) 2001-2016 Food and Agriculture Organization of the
  ~ United Nations (FAO-UN), United Nations World Food Programme (WFP)
  ~ and United Nations Environment Programme (UNEP)
  ~
  ~ This program is free software; you can redistribute it and/or modify
  ~ it under the terms of the GNU General Public License as published by
  ~ the Free Software Foundation; either version 2 of the License, or (at
  ~ your option) any later version.
  ~
  ~ This program is distributed in the hope that it will be useful, but
  ~ WITHOUT ANY WARRANTY; without even the implied warranty of
  ~ MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
  ~ General Public License for more details.
  ~
  ~ You should have received a copy of the GNU General Public License
  ~ along with this program; if not, write to the Free Software
  ~ Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA
  ~
  ~ Contact: Jeroen Ticheler - FAO - Viale delle Terme di Caracalla 2,
  ~ Rome - Italy. email: geonetwork@osgeo.org
  -->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:mcp="http://schemas.aodn.org.au/mcp-2.0"
                xmlns:gmd="http://www.isotc211.org/2005/gmd"
                xmlns:gco="http://www.isotc211.org/2005/gco"
                xmlns:gmx="http://www.isotc211.org/2005/gmx"
                xmlns:gml="http://www.opengis.net/gml"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:tr="java:org.fao.geonet.api.records.formatters.SchemaLocalizations"
                xmlns:gn-fn-render="http://geonetwork-opensource.org/xsl/functions/render"
                xmlns:gn-fn-metadata="http://geonetwork-opensource.org/xsl/functions/metadata"
                xmlns:gn-fn-iso19139="http://geonetwork-opensource.org/xsl/functions/profiles/iso19139"
                xmlns:saxon="http://saxon.sf.net/"
                version="2.0"
                extension-element-prefixes="saxon"
                exclude-result-prefixes="#all">
  <!-- This formatter render an ISO19139.mcp record based on the
  editor configuration file.


  The layout is made in 2 modes:
  * render-field taking care of elements (eg. sections, label)
  * render-value taking care of element values (eg. characterString, URL)

  3 levels of priority are defined: 100, 50, none

  -->

  <!-- Thesauri in marlin2 records have to be displayed in a manner that (supposedly) makes sense
       to the user ie. most important thesaurus first - this variable does that using thesaurus id
       the name is just a helper to identify the id 
       -->

  <xsl:variable name="thesauri">
          <thesauri>
            <thesaurus>
              <name>GCMD Keywords</name>
              <id>geonetwork.thesaurus.external.theme.gcmd_keywords</id>
            </thesaurus>
            <thesaurus>
              <name>CSIRO Areas of Interest</name>
              <id>geonetwork.thesaurus.register.discipline.urn:marlin.csiro.au:keywords:cmarAOI</id>
            </thesaurus>
            <thesaurus>
              <name>CSIRO Global Project List</name>
              <id>geonetwork.thesaurus.register.project.urn:marlin.csiro.au:globalprojectregister</id>
            </thesaurus>
            <thesaurus>
              <name>CSIRO Project List</name>
              <id>geonetwork.thesaurus.register.project.urn:marlin.csiro.au:projectregister</id>
            </thesaurus>
            <thesaurus>
              <name>CSIRO Source List</name>
              <id>geonetwork.thesaurus.register.dataSource.urn:marlin.csiro.au:sourceregister</id>
            </thesaurus>
            <thesaurus>
              <name>CSIRO Survey List</name>
              <id>geonetwork.thesaurus.register.survey.urn:marlin.csiro.au:surveyregister</id>
            </thesaurus>
            <thesaurus>
              <name>CSIRO Standard Data Types</name>
              <id>geonetwork.thesaurus.register.discipline.urn:marlin.csiro.au:keywords:standardDataType</id>
            </thesaurus>
            <thesaurus>
              <name>MCP Collection Methods</name>
              <id>geonetwork.thesaurus.external.theme.mcp_collection_methods</id>
            </thesaurus>
            <!-- This is the old equipment list - to be deleted soon -->
            <thesaurus>
              <name>CSIRO Equipment List</name>
              <id>geonetwork.thesaurus.register.equipment.urn:marlin.csiro.au:keywords:equipment</id>
            </thesaurus>
            <thesaurus>
              <name>CSIRO Equipment List</name>
              <id>geonetwork.thesaurus.register.equipment.urn:marlin.csiro.au:Equipment</id>
            </thesaurus>
            <thesaurus>
              <name>MCP Geographic Extent Names</name>
              <id>geonetwork.thesaurus.external.place.mcp_regions</id>
            </thesaurus>
            <thesaurus>
              <name>CSIRO Defined Regions</name>
              <id>geonetwork.thesaurus.register.place.urn:marlin.csiro.au:definedregions</id>
            </thesaurus>
            <thesaurus>
              <name>AODN Geographic Extent Names</name>
              <id>geonetwork.thesaurus.register.place.urn:aodn.org.au:geographicextents</id>
            </thesaurus>
            <thesaurus>
              <name>Australian National Species List</name>
              <id>geonetwork.thesaurus.external.taxon.nsl_species_all</id>
            </thesaurus>
            <thesaurus>
              <name>World Register of Marine Species</name>
              <id>geonetwork.thesaurus.register.taxon.urn:lsid:marinespecies.org:taxname</id>
            </thesaurus>
          </thesauri>
  </xsl:variable>


  <!-- Load the editor configuration to be able
  to render the different views -->
  <xsl:variable name="configuration"
                select="document('../../layout/config-editor.xml')"/>

 <!-- Required for utility-fn.xsl -->
  <xsl:variable name="editorConfig"
                select="document('../../layout/config-editor.xml')"/>

  <!-- Some utility -->
  <xsl:include href="../../layout/evaluate.xsl"/>
  <xsl:include href="../../../iso19139/layout/utility-tpl.xsl"/>
  <xsl:include href="../../../iso19139/layout/utility-fn.xsl"/>

  <!-- The core formatter XSL layout based on the editor configuration -->
  <xsl:include href="sharedFormatterDir/xslt/render-layout.xsl"/>
  <!--<xsl:include href="../../../../../data/formatter/xslt/render-layout.xsl"/>-->

  <!-- Define the metadata to be loaded for this schema plugin-->
  <xsl:variable name="metadata"
                select="/root/mcp:MD_Metadata"/>

  <xsl:variable name="langId" select="gn-fn-iso19139:getLangId($metadata, $language)"/>

  <!-- Specific schema rendering -->
  <xsl:template mode="getMetadataTitle" match="mcp:MD_Metadata">
    <xsl:for-each select="gmd:identificationInfo/*/gmd:citation/*/gmd:title">
      <xsl:call-template name="localised">
        <xsl:with-param name="langId" select="$langId"/>
      </xsl:call-template>
    </xsl:for-each>
  </xsl:template>

  <xsl:template mode="getMetadataAbstract" match="mcp:MD_Metadata">
    <xsl:for-each select="gmd:identificationInfo/*/gmd:abstract">
      <xsl:call-template name="localised">
        <xsl:with-param name="langId" select="$langId"/>
      </xsl:call-template>
    </xsl:for-each>
  </xsl:template>

  <xsl:template mode="getMetadataHierarchyLevel" match="mcp:MD_Metadata">
    <xsl:value-of select="gmd:hierarchyLevel/gmd:MD_ScopeCode/@codeListValue"/>
  </xsl:template>

  <xsl:template mode="getMetadataHeader" match="mcp:MD_Metadata">
  </xsl:template>


  <!-- Most of the elements are ... -->
  <xsl:template mode="render-field"
                match="*[gco:Integer|gco:Decimal|
       gco:Boolean|gco:Real|gco:Measure|gco:Length|gco:Distance|
       gco:Angle|gmx:FileName|
       gco:Scale|gco:Record|gco:RecordType|gmx:MimeFileType|gmd:URL|
       gco:LocalName|gmd:PT_FreeText|gml:beginPosition|gml:endPosition|
       gco:Date|gco:DateTime|*/@codeListValue]"
                priority="50">
    <xsl:param name="fieldName" select="''" as="xs:string"/>

    <dl>
      <dt>
        <xsl:value-of select="if ($fieldName)
                                then $fieldName
                                else tr:node-label(tr:create($schema), name(), null)"/>
      </dt>
      <dd>
        <xsl:apply-templates mode="render-value" select="*|*/@codeListValue"/>
        <xsl:apply-templates mode="render-value" select="@*"/>
      </dd>
    </dl>
  </xsl:template>

  <xsl:template mode="render-field"
                match="*[gco:CharacterString]"
                priority="50">
    <xsl:param name="fieldName" select="''" as="xs:string"/>

    <dl>
      <dt>
        <xsl:value-of select="if ($fieldName)
                                then $fieldName
                                else tr:node-label(tr:create($schema), name(), null)"/>
      </dt>
      <dd>
        <xsl:apply-templates mode="render-value" select="."/>
        <xsl:apply-templates mode="render-value" select="@*"/>
      </dd>
    </dl>
  </xsl:template>

  <!-- Some elements are only containers so bypass them -->
  <xsl:template mode="render-field"
                match="*[count(gmd:*[name() != 'gmd:PT_FreeText']) = 1]"
                priority="50">

    <xsl:apply-templates mode="render-value" select="@*"/>
    <xsl:apply-templates mode="render-field" select="*"/>
  </xsl:template>

	<!-- override the ordering defined by the fields in the advanced tab of 
       config-editor.xml so we can sort the descriptive keywords in the order
       we defined above... -->
  <xsl:template mode="render-field" match="mcp:MD_DataIdentification[gmd:descriptiveKeywords]" priority="100">
    <xsl:apply-templates mode="render-field" select="gmd:citation"/>
    <xsl:apply-templates mode="render-field" select="gmd:abstract"/>
    <xsl:apply-templates mode="render-field" select="gmd:purpose"/>
    <xsl:apply-templates mode="render-field" select="gmd:credit"/>
    <xsl:apply-templates mode="render-field" select="gmd:status"/>
    <xsl:apply-templates mode="render-field" select="mcp:resourceContactInfo"/>
    <xsl:apply-templates mode="render-field" select="gmd:resourceMaintenance"/>
    <xsl:apply-templates mode="render-field" select="gmd:graphicOverview"/>
    <xsl:apply-templates mode="render-field" select="gmd:resourceFormat"/>

    <xsl:apply-templates mode="render-field" select="gmd:topicCategory"/>
		<xsl:variable name="theKeys" select="."/>
		<!-- process keywords in order specified in variable $thesauri above -->
		<xsl:for-each select="$thesauri/thesauri/thesaurus">
			<xsl:variable name="currentThesaurus" select="id"/>
			<xsl:apply-templates mode="descriptive-keyword" select="$theKeys/gmd:descriptiveKeywords[gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:identifier/gmd:MD_Identifier/gmd:code/gmx:Anchor=$currentThesaurus]"/>	
		</xsl:for-each>

    <xsl:apply-templates mode="render-field" select="gmd:resourceSpecificUsage"/>
    <xsl:apply-templates mode="render-field" select="gmd:resourceConstraints"/>
    <xsl:apply-templates mode="render-field" select="gmd:aggregationInfo"/>
    <xsl:apply-templates mode="render-field" select="gmd:spatialRepresentationType"/>
    <xsl:apply-templates mode="render-field" select="gmd:spatialResolution"/>
    <xsl:apply-templates mode="render-field" select="gmd:environmentDescription"/>
    <xsl:apply-templates mode="render-field" select="gmd:extent"/>
    <xsl:apply-templates mode="render-field" select="gmd:supplementalInformation"/>
    <xsl:apply-templates mode="render-field" select="mcp:samplingFrequency"/>
    <xsl:apply-templates mode="render-field" select="mcp:dataParameters"/>
  </xsl:template>

  <!-- Display thesaurus name and the list of keywords -->
  <xsl:template mode="descriptive-keyword"
                match="gmd:descriptiveKeywords[*/gmd:thesaurusName/gmd:CI_Citation/gmd:title]"
                priority="100">
    <dl class="gn-keyword">
      <dt>
        <xsl:apply-templates mode="render-value"
                             select="*/gmd:thesaurusName/gmd:CI_Citation/gmd:title/*"/>

        <xsl:if test="*/gmd:type/*[@codeListValue != '']">
          (<xsl:apply-templates mode="render-value"
                                select="*/gmd:type/*/@codeListValue"/>)
        </xsl:if>
      </dt>
      <dd>
        <div>
          <ul>
            <li>
              <xsl:for-each select="*/gmd:keyword">
                <xsl:apply-templates mode="render-value"
                                     select="."/><xsl:if test="position() != last()">, </xsl:if>
              </xsl:for-each>
            </li>
          </ul>
        </div>
      </dd>
    </dl>
  </xsl:template>

  <xsl:template mode="descriptive-keyword"
                match="gmd:descriptiveKeywords[not(*/gmd:thesaurusName/gmd:CI_Citation/gmd:title)]"
                priority="100">
    <dl class="gn-keyword">
      <dt>
        <xsl:value-of select="$schemaStrings/noThesaurusName"/>
        <xsl:if test="*/gmd:type/*[@codeListValue != '']">
          (<xsl:apply-templates mode="render-value"
                                select="*/gmd:type/*/@codeListValue"/>)
        </xsl:if>
      </dt>
      <dd>
        <div>
          <ul>
            <li>
              <xsl:for-each select="*/gmd:keyword">
                <xsl:apply-templates mode="render-value"
                                     select="."/><xsl:if test="position() != last()">, </xsl:if>
              </xsl:for-each>
            </li>
          </ul>
        </div>
      </dd>
    </dl>
  </xsl:template>

  <!-- Some major sections are boxed -->
  <xsl:template mode="render-field"
                match="*[name() = $configuration/editor/fieldsWithFieldset/name
    or @gco:isoType = $configuration/editor/fieldsWithFieldset/name]|
      gmd:report/*|
      gmd:result/*|
      gmd:extent[name(..)!='gmd:EX_TemporalExtent']|
      *[$isFlatMode = false() and gmd:* and not(gco:CharacterString) and not(gmd:URL)]">

    <div class="entry name">
      <h3>
        <xsl:value-of select="tr:node-label(tr:create($schema), name(), null)"/>
        <xsl:apply-templates mode="render-value"
                             select="@*"/>
      </h3>
      <div class="target">
        <xsl:apply-templates mode="render-field" select="*"/>
      </div>
    </div>
  </xsl:template>

  <xsl:template mode="render-field" match="mcp:resourceContactInfo"
                priority="100">
    <div class="gn-contact">
      <h3>
        <i class="fa fa-envelope">&#160;</i>
        <xsl:apply-templates mode="render-value"
                             select="*/mcp:role/*/@codeListValue"/>
      </h3>
      <div class="row">
        <div class="col-md-6">
          <address itemprop="author"
                   itemscope="itemscope"
                   itemtype="http://schema.org/Organization">
            <strong>
                <xsl:apply-templates mode="mcp-html" select="*/mcp:party/*/mcp:individual"/>
            </strong>
            <br/>
            <xsl:variable name="organisationName" select="*/mcp:party/*/mcp:name/*"/>
            <!-- NOTE: Show only the first address in the contact info SP Nov. 2015 -->
            <xsl:apply-templates mode="mcp-html" select="*/mcp:party/*/mcp:contactInfo[1]">
              <xsl:with-param name="organisationName" select="$organisationName"/>
            </xsl:apply-templates>
          </address>
        </div>
      </div>
    </div>
  </xsl:template>

  <xsl:template mode="mcp-html" match="mcp:individual">
    <ul>
      <li style="list-style-type: none;">
        <xsl:value-of select="descendant::mcp:name/*"/>
        <xsl:if test="normalize-space(descendant::mcp:positionName/*)">
          <xsl:value-of select="concat(', ',descendant::mcp:positionName/*)"/>
        </xsl:if>
      </li>
    </ul>
  </xsl:template>

  <xsl:template mode="mcp-html" match="mcp:contactInfo">
    <xsl:param name="organisationName"/>
    <ul>
      <li style="list-style-type: none;"><xsl:value-of select="$organisationName"/></li>
      <li style="list-style-type: none;"><xsl:value-of select="descendant::gmd:deliveryPoint/*"/></li>
      <li style="list-style-type: none;"><xsl:value-of select="descendant::gmd:city/*"/></li>
      <li style="list-style-type: none;"><xsl:value-of select="descendant::gmd:administrativeArea/*"/></li>
      <li style="list-style-type: none;"><xsl:value-of select="concat(descendant::gmd:country/*,' ',descendant::gmd:postalCode/*)"/></li>
      <xsl:if test="normalize-space(descendant::gmd:electronicMailAddress/*)">
        <li style="list-style-type: none;"><xsl:value-of select="concat('Email: ',descendant::gmd:electronicMailAddress/*)"/></li>
      </xsl:if>
      <xsl:if test="normalize-space(descendant::gmd:voice/*)">
        <li style="list-style-type: none;"><xsl:value-of select="concat('Phone: ',descendant::gmd:voice/*)"/></li>
      </xsl:if>
    </ul>
  </xsl:template>

  <!-- Bbox is displayed with an overview and the geom displayed on it
  and the coordinates displayed around -->
  <xsl:template mode="render-field"
                match="gmd:EX_GeographicBoundingBox[
          gmd:westBoundLongitude/gco:Decimal != '']">
    <xsl:copy-of select="gn-fn-render:bbox(
                            xs:double(gmd:westBoundLongitude/gco:Decimal),
                            xs:double(gmd:southBoundLatitude/gco:Decimal),
                            xs:double(gmd:eastBoundLongitude/gco:Decimal),
                            xs:double(gmd:northBoundLatitude/gco:Decimal))"/>
  </xsl:template>


  <!-- A contact is displayed with its role as header -->
  <xsl:template mode="render-field"
                match="*[gmd:CI_ResponsibleParty]"
                priority="100">
    <xsl:variable name="email">
      <xsl:for-each select="*/gmd:contactInfo/
                                      */gmd:address/*/gmd:electronicMailAddress">
        <xsl:apply-templates mode="render-value"
                             select="."/><xsl:if test="position() != last()">, </xsl:if>
      </xsl:for-each>
    </xsl:variable>

    <!-- Display name is <org name> - <individual name> (<position name> -->
    <xsl:variable name="displayName">
      <xsl:choose>
        <xsl:when
          test="*/gmd:organisationName and */gmd:individualName">
          <!-- Org name may be multilingual -->
          <xsl:apply-templates mode="render-value"
                               select="*/gmd:organisationName"/>
          -
          <xsl:value-of select="*/gmd:individualName"/>
          <xsl:if test="*/gmd:positionName">
            (<xsl:apply-templates mode="render-value"
                                  select="*/gmd:positionName"/>)
          </xsl:if>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="*/gmd:organisationName|*/gmd:individualName"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <div class="gn-contact">
      <h3>
        <i class="fa fa-envelope">&#160;</i>
        <xsl:apply-templates mode="render-value"
                             select="*/gmd:role/*/@codeListValue"/>
      </h3>
      <div class="row">
        <div class="col-md-6">
          <address itemprop="author"
                   itemscope="itemscope"
                   itemtype="http://schema.org/Organization">
            <strong>
              <xsl:choose>
                <xsl:when test="$email">
                  <a href="mailto:{normalize-space($email)}">
                    <xsl:value-of select="$displayName"/>&#160;
                  </a>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="$displayName"/>
                </xsl:otherwise>
              </xsl:choose>
            </strong>
            <br/>
            <xsl:for-each select="*/gmd:contactInfo/*">
              <xsl:for-each select="gmd:address/*">
                <div itemprop="address"
                      itemscope="itemscope"
                      itemtype="http://schema.org/PostalAddress">
                  <xsl:for-each select="gmd:deliveryPoint">
                    <span itemprop="streetAddress">
                      <xsl:apply-templates mode="render-value" select="."/>
                    </span>
                  </xsl:for-each>
                  <xsl:for-each select="gmd:city">
                    <span itemprop="addressLocality">
                      <xsl:apply-templates mode="render-value" select="."/>
                    </span>
                  </xsl:for-each>
                  <xsl:for-each select="gmd:administrativeArea">
                    <span itemprop="addressRegion">
                      <xsl:apply-templates mode="render-value" select="."/>
                    </span>
                  </xsl:for-each>
                  <xsl:for-each select="gmd:postalCode">
                    <span itemprop="postalCode">
                      <xsl:apply-templates mode="render-value" select="."/>
                    </span>
                  </xsl:for-each>
                  <xsl:for-each select="gmd:country">
                    <span itemprop="addressCountry">
                      <xsl:apply-templates mode="render-value" select="."/>
                    </span>
                  </xsl:for-each>
                </div>
                <br/>
              </xsl:for-each>
            </xsl:for-each>
          </address>
        </div>
        <div class="col-md-6">
          <address>
            <xsl:for-each select="*/gmd:contactInfo/*">
              <xsl:for-each select="gmd:phone/*/gmd:voice[normalize-space(.) != '']">
                <div itemprop="contactPoint"
                      itemscope="itemscope"
                      itemtype="http://schema.org/ContactPoint">
                  <meta itemprop="contactType"
                        content="{ancestor::gmd:CI_ResponsibleParty/*/gmd:role/*/@codeListValue}"/>

                  <xsl:variable name="phoneNumber">
                    <xsl:apply-templates mode="render-value" select="."/>
                  </xsl:variable>
                  <i class="fa fa-phone">&#160;</i>
                  <a href="tel:{$phoneNumber}">
                    <xsl:value-of select="$phoneNumber"/>&#160;
                  </a>
                </div>
              </xsl:for-each>
              <xsl:for-each select="gmd:phone/*/gmd:facsimile[normalize-space(.) != '']">
                <xsl:variable name="phoneNumber">
                  <xsl:apply-templates mode="render-value" select="."/>
                </xsl:variable>
                <i class="fa fa-fax">&#160;</i>
                <a href="tel:{normalize-space($phoneNumber)}">
                  <xsl:value-of select="normalize-space($phoneNumber)"/>&#160;
                </a>
              </xsl:for-each>

              <xsl:for-each select="gmd:hoursOfService">
                <span itemprop="hoursAvailable"
                      itemscope="itemscope"
                      itemtype="http://schema.org/OpeningHoursSpecification">
                  <xsl:apply-templates mode="render-field"
                                       select="."/>
                </span>
              </xsl:for-each>

              <xsl:apply-templates mode="render-field"
                                   select="gmd:contactInstructions"/>
              <xsl:apply-templates mode="render-field"
                                   select="gmd:onlineResource"/>

            </xsl:for-each>
          </address>
        </div>
      </div>
    </div>
  </xsl:template>

  <!-- Metadata linkage -->
  <xsl:template mode="render-field"
                match="gmd:fileIdentifier"
                priority="100">
    <dl>
      <dt>
        <xsl:value-of select="tr:node-label(tr:create($schema), name(), null)"/>
      </dt>
      <dd>
        <xsl:apply-templates mode="render-value" select="*"/>
        <xsl:apply-templates mode="render-value" select="@*"/>
        <a class="btn btn-link" href="{$nodeUrl}api/records/{$metadataId}/formatters/xml">
          <i class="fa fa-file-code-o fa-2x">&#160;</i>
          <span data-translate="">metadataInXML</span>
        </a>
      </dd>
    </dl>
  </xsl:template>

  <!-- Linkage -->
  <xsl:template mode="render-field"
                match="*[gmd:CI_OnlineResource and */gmd:linkage/gmd:URL != '']"
                priority="100">
    <dl class="gn-link"
        itemprop="distribution"
        itemscope="itemscope"
        itemtype="http://schema.org/DataDownload">
      <dt>
        <xsl:value-of select="tr:node-label(tr:create($schema), name(), null)"/>
      </dt>
      <dd>
        <xsl:variable name="linkUrl"
                      select="*/gmd:linkage/gmd:URL"/>
        <xsl:variable name="linkName">
          <xsl:choose>
            <xsl:when test="*/gmd:name[* != '']">
              <xsl:apply-templates mode="render-value"
                                   select="*/gmd:name"/>
            </xsl:when>
            <xsl:when test="*/gmd:description[* != '']">
              <xsl:apply-templates mode="render-value"
                                   select="*/gmd:description"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$linkUrl"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>

        <a href="{$linkUrl}" title="{$linkName}">
          <xsl:value-of select="$linkName"/>
        </a>
        &#160;

        <xsl:if test="*/gmd:description[* != '' and * != $linkName]">
          <p>
            <xsl:apply-templates mode="render-value"
                                 select="*/gmd:description"/>
          </p>
        </xsl:if>
      </dd>
    </dl>
  </xsl:template>

  <!-- Identifier -->
  <xsl:template mode="render-field"
                match="*[(gmd:RS_Identifier or gmd:MD_Identifier) and
                  */gmd:code/gco:CharacterString != '']"
                priority="100">
    <dl class="gn-code">
      <dt>
        <xsl:value-of select="tr:node-label(tr:create($schema), name(), null)"/>
      </dt>
      <dd>

        <xsl:if test="*/gmd:codeSpace">
          <xsl:apply-templates mode="render-value"
                               select="*/gmd:codeSpace"/>
          /
        </xsl:if>
        <xsl:apply-templates mode="render-value"
                             select="*/gmd:code"/>
        <xsl:if test="*/gmd:version">
          /
          <xsl:apply-templates mode="render-value"
                               select="*/gmd:version"/>
        </xsl:if>
        <p>
          <xsl:apply-templates mode="render-field"
                               select="*/gmd:authority"/>
        </p>
      </dd>
    </dl>
  </xsl:template>

  <!-- Display all graphic overviews in one block -->
  <xsl:template mode="render-field"
                match="gmd:graphicOverview[1]"
                priority="100">
    <dl>
      <dt>
        <xsl:value-of select="tr:node-label(tr:create($schema), name(), null)"/>
      </dt>
      <dd>
        <ul>
          <xsl:for-each select="parent::node()/gmd:graphicOverview">
            <xsl:variable name="label">
              <xsl:apply-templates mode="localised"
                                   select="gmd:MD_BrowseGraphic/gmd:fileDescription"/>
            </xsl:variable>
            <li>
              <img src="{gmd:MD_BrowseGraphic/gmd:fileName/*}"
                   alt="{$label}"
                   class="img-thumbnail"/>
            </li>
          </xsl:for-each>
        </ul>
      </dd>
    </dl>
  </xsl:template>
  <xsl:template mode="render-field"
                match="gmd:graphicOverview[position() > 1]"
                priority="100"/>


  <xsl:template mode="render-field"
                match="gmd:distributionFormat[1]"
                priority="100">
    <dl class="gn-format">
      <dt>
        <xsl:value-of select="tr:node-label(tr:create($schema), name(), null)"/>
      </dt>
      <dd>
        <ul>
          <xsl:for-each select="parent::node()/gmd:distributionFormat">
            <li>
              <xsl:apply-templates mode="render-value"
                                   select="*/gmd:name"/>
              (<xsl:apply-templates mode="render-value"
                                    select="*/gmd:version"/>)
              <p>
                <xsl:apply-templates mode="render-field"
                                     select="*/(gmd:amendmentNumber|gmd:specification|
                              gmd:fileDecompressionTechnique|gmd:formatDistributor)"/>
              </p>
            </li>
          </xsl:for-each>
        </ul>
      </dd>
    </dl>
  </xsl:template>


  <xsl:template mode="render-field"
                match="gmd:distributionFormat[position() > 1]"
                priority="100"/>

  <!-- Date -->
  <xsl:template mode="render-field"
                match="gmd:date"
                priority="100">
    <dl class="gn-date">
      <dt>
        <xsl:value-of select="tr:node-label(tr:create($schema), name(), null)"/>
        <xsl:if test="*/gmd:dateType/*[@codeListValue != '']">
          (<xsl:apply-templates mode="render-value"
                                select="*/gmd:dateType/*/@codeListValue"/>)
        </xsl:if>
      </dt>
      <dd>
        <xsl:apply-templates mode="render-value"
                             select="*/gmd:date/*"/>
      </dd>
    </dl>
  </xsl:template>


  <!-- Enumeration -->
  <xsl:template mode="render-field"
                match="gmd:topicCategory[1]|gmd:obligation[1]|gmd:pointInPixel[1]"
                priority="100">
    <dl class="gn-date">
      <dt>
        <xsl:value-of select="tr:node-label(tr:create($schema), name(), null)"/>
      </dt>
      <dd>
        <ul>
          <xsl:for-each select="parent::node()/(gmd:topicCategory|gmd:obligation|gmd:pointInPixel)">
            <li>
              <xsl:apply-templates mode="render-value"
                                   select="*"/>
            </li>
          </xsl:for-each>
        </ul>
      </dd>
    </dl>
  </xsl:template>
  <xsl:template mode="render-field"
                match="gmd:topicCategory[position() > 1]|
                        gmd:obligation[position() > 1]|
                        gmd:pointInPixel[position() > 1]"
                priority="100"/>


  <!-- Link to other metadata records -->
  <xsl:template mode="render-field"
                match="*[@uuidref]"
                priority="100">
    <xsl:variable name="nodeName" select="name()"/>

    <!-- Only render the first element of this kind and render a list of
    following siblings. -->
    <xsl:variable name="isFirstOfItsKind"
                  select="count(preceding-sibling::node()[name() = $nodeName]) = 0"/>
    <xsl:if test="$isFirstOfItsKind">
      <dl class="gn-md-associated-resources">
        <dt>
          <xsl:value-of select="tr:node-label(tr:create($schema), name(), null)"/>
        </dt>
        <dd>
          <ul>
            <xsl:for-each select="parent::node()/*[name() = $nodeName]">
              <li>
                <a href="#uuid={@uuidref}">
                  <i class="fa fa-link">&#160;</i>
                  <xsl:value-of select="gn-fn-render:getMetadataTitle(@uuidref, $language)"/>
                </a>
              </li>
            </xsl:for-each>
          </ul>
        </dd>
      </dl>
    </xsl:if>
  </xsl:template>

 <!-- Elements to avoid render -->
  <xsl:template mode="render-field" match="gmd:PT_Locale" priority="100"/>

  <!-- Traverse the tree -->
  <xsl:template mode="render-field"
                match="*">
    <xsl:apply-templates mode="render-field"/>
  </xsl:template>


  <!-- ########################## -->
  <!-- Render values for text ... -->
   <xsl:template mode="render-value"
                match="*[gco:CharacterString]">

    <xsl:apply-templates mode="localised" select=".">
      <xsl:with-param name="langId" select="$langId"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template mode="render-value"
                match="gco:Integer|gco:Decimal|
       gco:Boolean|gco:Real|gco:Measure|gco:Length|gco:Distance|gco:Angle|gmx:FileName|
       gco:Scale|gco:Record|gco:RecordType|gmx:MimeFileType|gmd:URL|
       gco:LocalName|gml:beginPosition|gml:endPosition">

    <xsl:choose>
      <xsl:when test="contains(., 'http')">
        <!-- Replace hyperlink in text by an hyperlink -->
        <xsl:variable name="textWithLinks"
                      select="replace(., '([a-z][\w-]+:/{1,3}[^\s()&gt;&lt;]+[^\s`!()\[\]{};:'&apos;&quot;.,&gt;&lt;?«»“”‘’])',
                                    '&lt;a href=''$1''&gt;$1&lt;/a&gt;')"/>

        <xsl:if test="$textWithLinks != ''">
          <xsl:copy-of select="saxon:parse(
                          concat('&lt;p&gt;',
                          replace($textWithLinks, '&amp;', '&amp;amp;'),
                          '&lt;/p&gt;'))"/>
        </xsl:if>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="normalize-space(.)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- ... URL -->
  <xsl:template mode="render-value"
                match="gmd:URL">
    <a href="{.}">
      <xsl:value-of select="."/>&#160;
    </a>
  </xsl:template>

  <!-- ... Dates - formatting is made on the client side by the directive  -->
  <xsl:template mode="render-value"
                match="gco:Date[matches(., '[0-9]{4}')]">
    <span data-gn-humanize-time="{.}" data-format="YYYY"></span>
  </xsl:template>

  <xsl:template mode="render-value"
                match="gco:Date[matches(., '[0-9]{4}-[0-9]{2}')]">
    <span data-gn-humanize-time="{.}" data-format="MMM YYYY"></span>
  </xsl:template>

  <xsl:template mode="render-value"
                match="gco:Date[matches(., '[0-9]{4}-[0-9]{2}-[0-9]{2}')]">
    <span data-gn-humanize-time="{.}" data-format="DD MMM YYYY"></span>
  </xsl:template>

  <xsl:template mode="render-value"
                match="gco:DateTime[matches(., '[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}')]">
    <span data-gn-humanize-time="{.}"></span>
  </xsl:template>

  <xsl:template mode="render-value"
                match="gco:Date|gco:DateTime">
    <span data-gn-humanize-time="{.}"></span>
  </xsl:template>

  <xsl:template mode="render-value"
                match="gmd:language/gco:CharacterString">
    <span data-translate="">
      <xsl:value-of select="."/>
    </span>
  </xsl:template>

  <!-- ... Codelists -->
  <xsl:template mode="render-value"
                match="@codeListValue">
    <xsl:variable name="id" select="."/>
    <xsl:variable name="codelistTranslation"
                  select="tr:codelist-value-label(
                            tr:create($schema),
                            parent::node()/local-name(), $id)"/>
    <xsl:choose>
      <xsl:when test="$codelistTranslation != ''">

        <xsl:variable name="codelistDesc"
                      select="tr:codelist-value-desc(
                            tr:create($schema),
                            parent::node()/local-name(), $id)"/>
        <span title="{$codelistDesc}">
          <xsl:value-of select="$codelistTranslation"/>
        </span>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$id"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Enumeration -->
  <xsl:template mode="render-value"
                match="gmd:MD_TopicCategoryCode|
                        gmd:MD_ObligationCode|
                        gmd:MD_PixelOrientationCode">
    <xsl:variable name="id" select="."/>
    <xsl:variable name="codelistTranslation"
                  select="tr:codelist-value-label(
                            tr:create($schema),
                            local-name(), $id)"/>
    <xsl:choose>
      <xsl:when test="$codelistTranslation != ''">

        <xsl:variable name="codelistDesc"
                      select="tr:codelist-value-desc(
                            tr:create($schema),
                            local-name(), $id)"/>
        <span title="{$codelistDesc}">
          <xsl:value-of select="$codelistTranslation"/>
        </span>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$id"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template mode="render-value"
                match="@gco:nilReason[. = 'withheld']"
                priority="100">
    <i class="fa fa-lock text-warning" title="{{{{'withheld' | translate}}}}">&#160;</i>
  </xsl:template>

  <xsl:template mode="render-value"
                match="@*"/>

</xsl:stylesheet>
