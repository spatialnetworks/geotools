import math
import ogr

# Create an ESRI shapefile of parallels and meridians for a MapServer
# world map.

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
for j in range(0,18):
    y = 10*float(j-9)
    if j == 0:
      y = -88

    for i in range(0, 360):
        line = ogr.Geometry(type=ogr.wkbLineString)

        # hack: MapServer has trouble within .1 decimal degrees of the
        # dateline
        if i == 0:
            x1 = -179.9
            x2 = -179.0
        elif i == 359:
            x1 = 179.0
            x2 = 179.9
        else:
            x1 = float(i-180)
            x2 = x1 + 1.0

        line.AddPoint(x1, y)
        line.AddPoint(x2, y)

        f = ogr.Feature(feature_def=layer.GetLayerDefn())
        f.SetField(0, 0)
        f.SetField(1, y)
        f.SetField(2, math.fabs(y))
        f.SetGeometryDirectly(line)
        layer.CreateFeature(f)
        f.Destroy()



for i in range(0, 37):
    x = 10*float(i-18)

    # hack: MapServer has trouble within .1 decimal degrees of the
    # dateline
    #if i == 0:
    #    x = -179.9
    #if i == 36:
    #    x = 179.9

    for j in range(0, 170):
        line = ogr.Geometry(type=ogr.wkbLineString)
        y1 = float(j - 90)
        y2 = y1 + 1.0

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
