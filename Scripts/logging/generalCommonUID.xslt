<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:transform version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:output omit-xml-declaration="yes"/>

<xsl:key name="by-uid" match="Message" use="@uid" />
<xsl:key name="by-messagetrace-uid" match="MessageTrace" use="@uid" />

	<xsl:template match="/">

	  <xsl:choose>
	    <xsl:when test="/MessageTraces">
	      <MessageTraces>
	      <xsl:apply-templates select="//MessageTrace[generate-id(.) = generate-id(key('by-messagetrace-uid', @uid)[1])]" mode="grouped"/>
	      </MessageTraces>
	    </xsl:when>
	    <xsl:otherwise>
	       <xsl:apply-templates select="//Message[generate-id(.) = generate-id(key('by-uid', @uid)[1])]" mode="grouped"/>
	    </xsl:otherwise>
	  </xsl:choose>
	
	</xsl:template>


	<!-- for processing raw data-->
	<xsl:template match="Message" mode="grouped">
	  <xsl:variable name="currentUID" select="@uid"/>
	  <MessageTrace uid="{$currentUID}">
	    <xsl:apply-templates select="key('by-uid', @uid)"/>
	  </MessageTrace>
	</xsl:template>

	<xsl:template match="Message">
	  <xsl:apply-templates select="./.."/>
	</xsl:template>

	<xsl:template match="MessageItem">
	  <xsl:variable name="messType" select="Message[1]/@type"/>
	  <xsl:variable name="messDir" select="Message[1]/@direction"/>
	  <Message type="{$messType}">
	    <xsl:copy-of select="To"/>
	    <xsl:copy-of select="From"/>
	    <Current>
	    <xsl:choose>
	      <xsl:when test="$messDir = 'sent'">
		<xsl:value-of select="From"/>
	      </xsl:when>
	      <xsl:otherwise>
		<xsl:value-of select="To"/>
	      </xsl:otherwise>
	    </xsl:choose>
	    </Current>
	    <xsl:copy-of select="./../Date[1]"/>
	  </Message>
	</xsl:template>
	<!-- END for processing raw data-->

	<!-- for processing preprocessed data-->
	<xsl:template match="MessageTrace" mode="grouped">
	  <xsl:variable name="currentUID" select="@uid"/>
	  <MessageTrace uid="{$currentUID}">
	    <xsl:apply-templates select="key('by-messagetrace-uid', @uid)"/>
	  </MessageTrace>
	</xsl:template>

	<xsl:template match="MessageTrace">
	  <xsl:copy-of select="Message"/>
	</xsl:template>
	<!-- END for processing preprocessed data-->

</xsl:transform>
