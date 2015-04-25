<?xml version="1.0"?>
<p:pipeline
    version="1.0"
    xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:bhc="http://www.brookhavencollege.edu/xml/xproc">

    <!-- This provides the <bhc:xslt> step used below. -->
    <p:import href="bhc-xslt.xpl"/>

    <!-- The sequence of transformations we need to apply. -->
    <bhc:xslt stylesheet="remove-locations.xsl"/>
    <bhc:xslt stylesheet="divisions-1.xsl"/>
    <bhc:xslt stylesheet="divisions-2.xsl"/>
    <bhc:xslt stylesheet="subjects-1.xsl"/>
    <bhc:xslt stylesheet="subjects-2.xsl"/>
    <bhc:xslt stylesheet="types-1.xsl"/>
    <bhc:xslt stylesheet="types-2.xsl"/>
    <bhc:xslt stylesheet="core.xsl"/>
    <bhc:xslt stylesheet="consolidate-descriptions.xsl" />
</p:pipeline>
