#!/bin/python
import sys, os, glob
import pprint
try:
    import json
except:
    import simplejson as json
try:
    from osgeo import ogr
except:
    import ogr

# Usage:
# python weogeo_toc.py /full/path/to/shapefiles

def get_amigo_extensions(file):
    """Use the basename (left side of the ".") to find the companion files.
    For example, shapefiles will have 3 amigos: shx,dbf,prj
    """
    amigos = glob.glob(file.split(".")[0]+".*")

    amigo_list = []  #"amigos" are the other files that go with a SHP i.e. SHX,PRJ,DBF, etc.

    for amigo in amigos:  # FixMe: refactor this to obviate for loop
        ext = amigo.split("/")[-1].split(".")[-1]  # the extension is the right side of the "."
        if ext != "xml": amigo_list.append(ext)  #.shp.xml files don't go in this list
    
    # turn the list into a semicolon delimited string
    amigo_extensions = ";".join(amigo_list)
    
    #amigo_extensions = "shp;dbf;shx;prj"  # example return
    return amigo_extensions
    
def toc_example(layer_cnt,infiles,out_file_name):
    """Builds GeoJSON with one Feature for each of the "files"
    Writes the resulting GeoJSON file to the "out_file_name"
    """
    # "toc" is the dictionary that will be encoded to GeoJSON
    toc = {}
    toc["name"] = "NewFeatureType"
    toc["type"] = "FeatureCollection"
    toc["crs"] = {"type":"name",
                  # "properties" : {"name":"urn:ogc:def:crs:OGC:1.3:CRS83"}
                  # FixMe: Get CRS from data.
                  # This example uses the GeoJSON default: EPSG:4326
                 }
    
    # "features" is the list that holds all of the features in the GeoJSON
    features = []

    for cnt in range(len(infiles)):  
        
        # file name management and "path" determination
        head, tail = os.path.split(infiles[cnt])
        base, ext = os.path.splitext(tail)
        
        path = "./" + tail
        path = path.replace("\\","/")
        print path
        
        # get the shapefile's "amigos"
        amigo_extensions = get_amigo_extensions(infiles[cnt])
        
        # get the extents of the data
        driver = ogr.GetDriverByName('ESRI Shapefile')  #FixMe: could be any Vector file type
        datasource = driver.Open(infiles[cnt], 0)
        layer = datasource.GetLayer()
        extent = layer.GetExtent()
                
        # create a GeoJSON feature for the file
        features.append({
                "type":"Feature",
                 "geometry":{"type": "Polygon",
                 "coordinates":[[
                        [extent[0],extent[3]], #UL  X,Y
                        [extent[1],extent[3]], #UR  X,Y                            
                        [extent[1],extent[2]], #LR  X,Y
                        [extent[0],extent[2]], #LL  X,Y
                        [extent[0],extent[3]]  #UL  X,Y
                    ]]},
                 "properties":{
                    "PATH": path,
                    "EXTS": amigo_extensions,
                    "LAYERS":layer_cnt[cnt],  
                    "WEO_MISCELLANEOUS_FILE":"No",
                    "WEO_TYPE":"WEO_FEATURE"
                    }
                })
    
    # Create WeoGeo's LOOK_UP_TABLE Feature
    layers_properties = {}
    layers_properties["WEO_TYPE"] = "LOOK_UP_TABLE"
    for cnt in range(len(layer_cnt)+1):
        layers_properties[str(cnt)] = "WEOALL=WEOALL"  
        # Example:
        # 0 : "WEOALL=WEOALL"
        # 1 : "WEOALL=WEOALL"
        # etc.
    
    # Add the LOOK_UP_TABLE Feature to the features list
    features.append(
            {
                "type":"Feature",
                "geometry": None,
                "properties": layers_properties
            }
        )
    
    # add the features list to the ToC dictionary
    toc["features"] = features
    
    # create a JSON object
    e = json.JSONEncoder()
    
    # encode the ToC dictionary as (Geo)JSON
    #  and write the results to a text file
    out = open(out_file_name, "w")
    out.write(e.encode(toc))
    out.close()
    
    
if __name__ == "__main__":
    base_dir = sys.argv[1]
    # Search for ShapeFiles
    infiles = glob.glob(base_dir + "/*.shp")
    out_file_name = "{}/WeoGeoTableOfContents.json".format(base_dir)
    toc_example(range(len(infiles)),infiles,out_file_name)
    print "Done!"