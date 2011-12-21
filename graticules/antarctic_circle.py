import math
import ogr

# Create an ESRI shapefile of parallels and meridians for a MapServer
# world map.

filename = 'antarctic_circle.shp'
driver = ogr.GetDriverByName('ESRI Shapefile')
driver.DeleteDataSource(filename)
ds = driver.CreateDataSource(filename)
layer = ds.CreateLayer('antarctic_circle', geom_type=ogr.wkbLineString)


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
y = -66.5622

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



# destroying data source closes the output file
ds.Destroy()
