# Geocoding with Google Refine

## OpenStreetMap Nominatim API

1. Upload your dataset to Google Refine.

2. On the column you want to pass to the geocoder (like a `city, state` pair), click the dropdown and select "Edit column &rarr; Add column by fetching URLs..."

![Add column from a URL JSON response](http://f.cl.ly/items/3E0c043z3y2f2q240U0s/google-refine-geocoding-json.png)

```
'http://nominatim.openstreetmap.org/search?format=json&email=cmccormick@gmail.com&app=google-refine&q=' + escape(value, 'url')
```

3. Wait 10 years for the geocoder to return your results.

Once geocoding is complete and you have a fully populated column, select the `json` column and pick "Add column based on this column"

with(value.parseJson()[0]), pair, pair.lat)

