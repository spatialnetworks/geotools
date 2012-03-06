#!/usr/bin/env python
import math
import ogr


filename = 'graticule.shp'
driver = ogr.GetDriverByName('ESRI Shapefile')
driver.DeleteDataSource(filename)
ds = driver.CreateDataSource(filename)
layer = ds.CreateLayer('graticule', geom_type=ogr.wkbLineString)

# Create an integer field for classification
# 0: parallel
# 1: meridian
fd = ogr.FieldDefn('TYPE', ogr.OFTInteger)
fd.SetWidth(1)
fd.SetPrecision(0)
layer.CreateField(fd)

# Create two fields for labeling
fd = ogr.FieldDefn('VALUE', ogr.OFTReal)
fd.SetWidth(4)
fd.SetPrecision(4)
layer.CreateField(fd)

fd = ogr.FieldDefn('ABS_VALUE', ogr.OFTReal)
fd.SetWidth(4)
fd.SetPrecision(4)
layer.CreateField(fd)

# First, the parallels at 10 degree intervals, with one degree resolution
# 3600 instead of 2100 for entire world
for j in range(1000,3000):
    y = 0.05*float(j-(3600/2.0))
    print "Latitude # ", j
    for i in range(0, 720):
        line = ogr.Geometry(type=ogr.wkbLineString)

        # hack: MapServer has trouble within .1 decimal degrees of the
        # dateline
        #if i == 0:
        #    x1 = -179.9
        #    x2 = -179.0
        #elif i == 359:
        #    x1 = 179.0
        #    x2 = 179.9
        #else:
        # 360 - 360 = 0, 0 + 0.5 = 0.5
        # 361 - 360 = 1, 1 + 0.5 = 1.5
        # 360 * 0.5 = 180 = 180 + 0.5 = 180.5
        # 361 * 0.5 = 180.5 = 180.5 + 0.5 = 181.0
        x1 = float((i * 0.5) - 180)
        x2 = x1 + 0.5
        #print x1,x2

        line.AddPoint(x1, y)
        line.AddPoint(x2, y)

        f = ogr.Feature(feature_def=layer.GetLayerDefn())
        f.SetField(0, 0)
        f.SetField(1, y)
        f.SetField(2, math.fabs(y))
        f.SetGeometryDirectly(line)
        layer.CreateFeature(f)
        f.Destroy()


# Next, the meridians at 10 degree intervals and one degree resolution

#7200 instead of 3600 for entire world
for i in range(1000, 3600):
    x = 0.05*float(i-(7200/2.0))

    # hack: MapServer has trouble within .1 decimal degrees of the
    # dateline
    #if i == 0:
    #    x = -179.9
    #if i == 36:
    #    x = 179.9

    print "Longitude # ", i
    for j in range(10, 340):
        line = ogr.Geometry(type=ogr.wkbLineString)
        y1 = float((j * 0.5) - 90)
        y2 = y1 + 0.5

        line.AddPoint(x, y1)
        line.AddPoint(x, y2)

        f = ogr.Feature(feature_def=layer.GetLayerDefn())
        f.SetField(0, 1)
        f.SetField(1, x)
        f.SetField(2, math.fabs(x))
        f.SetGeometryDirectly(line)
        layer.CreateFeature(f)
        f.Destroy()

# destroying data source closes the output file
ds.Destroy()
