import altair as alt
import os


def save_chart_to_html(chart, filename="~/html/index.html"):
    """Save the chart to an HTML file."""
    filename = os.path.expanduser(filename)

    # Ensure the directory exists
    os.makedirs(os.path.dirname(filename), exist_ok=True)

    # Save the chart to the specified filename
    chart.save(filename)
    print(f"Chart automatically saved to {filename}")


def custom_repr_mimebundle_(self, include=None, exclude=None):
    """A wrapper to save the chart before rendering."""
    # Save the chart without attempting to display it again
    save_chart_to_html(self)
    # Proceed with Altair's normal rendering process
    return


# Ensure we don't override the method more than once
if not hasattr(alt.Chart, "_original_repr_mimebundle_"):
    alt.Chart._original_repr_mimebundle_ = alt.Chart._repr_mimebundle_

# Override Altair's _repr_mimebundle_ method
alt.Chart._repr_mimebundle_ = custom_repr_mimebundle_
