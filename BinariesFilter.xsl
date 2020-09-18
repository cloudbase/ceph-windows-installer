<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:wix="http://schemas.microsoft.com/wix/2006/wi">

<xsl:output method="xml" indent="yes" />

<xsl:template match="@*|node()">
  <xsl:copy>
    <xsl:apply-templates select="@*|node()"/>
  </xsl:copy>
</xsl:template>

<!-- We're using this filter to avoid duplicating the rbd-wnbd component,
     which is also used by the service component. -->
<xsl:key name="rbd-wnbd-search" match="wix:Component[contains(wix:File/@Source, 'rbd-wnbd.exe')]" use="@Id" />
<xsl:template match="wix:Component[key('rbd-wnbd-search', @Id)]" />

</xsl:stylesheet>
