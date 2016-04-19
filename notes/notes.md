### How to _not_ use Tableau & R

Let's say you want to use Tableau to help you understand the behaviour of your clustering algorithm. For the sake of this demonstration, we'll just use the `kmeans` algorithm, but the ideas here will generalize. To follow along, you'll need the iris data set and a running instance of `Rserve`.

_Note,_ you can bypass a lot of the setting up by just downloading `how_to_not_use_tabr.twb`. If you choose to not use this (because it was created with Tableau 9.3 and you have an older version), just download the `iris.csv` and then connect it as your data source.

First, we fire up Tableau, and load in the 


First things first, using `R` in Tableau can only happen through _calculated fields_. In particular, the `SCRIPT_BOOL`, `SCRIPT_INT`, `SCRIPT_REAL`, and/or `SCRIPT_STR` functions (I'll refer to this set of functions as "`SCRIPT_*`"). However, an astute Tableau user will immediately recognize that these user functions are actually [_table calculations_](). Since I'm no expert, I cannot tell you what the subtle implications are, but I can tell you two immediate consequences of this:

1. You'll need to make sure you perform unaggregated analysis. That is, you'll want to uncheck _Analysis > Aggregate measures_. 
2. Your analysis is pretty much terminated after the `SCRIPT_*` calculation.

To demonstrate these, let's look at the "Sample -- Superstore" data that ships with Tableau 9.x...

Say we wanted to do something as simple as calculating the median order size, by State, _in `R`_. The calculated field might look something like

```
SCRIPT_INT('median(.arg1)', SUM({FIXED [Order ID]: COUNT([Order ID])}))
```

where we have to use the LOD expression `{FIXED [Order ID]: COUNT([Order ID])}` to make sure that we are getting the number of items in a particular order, and then we have to throw all of that into a `SUM()`, since Tableau won't let us feed unaggregated, non-constant measures into a `SCRIPT_*()`.


The first consequence is reasonable. 
What do I mean by this? Simply put, you _cannot_ perform any further calculations on the measures you derive using a `SCRIPT_*` function. As a simple demonstration, let's look at the "Super Store" data (it came with my version of Tableau 9.x):

