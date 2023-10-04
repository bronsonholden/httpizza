defmodule HTTPizzaWeb.Slug do
  @style ~w(
    deep-dish thin brooklyn sicilian italian buffalo
    lasagna calzone hot-pocket bites
  )

  @cheese ~w(
    mozzarella cheddar provolone gruyere ricotta parmesan
    gouda
  )

  @topping ~w(
    pepperoni ham salami sausage chicken pineapple spinach
    onion mushroom olive broccolini bacon kale shrimp egg
    chorizo salami kielbasa jalapeno eggplant zucchini
    cauliflower corn broccoli steak potato duck cabbage
    squash sweet-potato relish
  )

  def generate(max_id \\ 99999) do
    [
      Enum.random(@style),
      Enum.random(@cheese),
      Enum.random(@topping),
      "#{:rand.uniform(max_id)}"
    ]
    |> Enum.join("-")
  end

  def humanize(slug, personal_organization_slug) do
    if slug == personal_organization_slug do
      "personal"
    else
      slug
    end
  end
end
