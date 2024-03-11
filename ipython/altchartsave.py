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
    return self._original_repr_mimebundle_(include=include, exclude=exclude)


# List of Altair chart types to override
chart_types = [
    alt.Chart,
    alt.LayerChart,
    alt.HConcatChart,
    alt.VConcatChart,
    alt.RepeatChart,
]

for chart_type in chart_types:
    # Ensure we don't override the method more than once
    if not hasattr(chart_type, "_original_repr_mimebundle_"):
        chart_type._original_repr_mimebundle_ = chart_type._repr_mimebundle_

    chart_type._repr_mimebundle_ = custom_repr_mimebundle_
