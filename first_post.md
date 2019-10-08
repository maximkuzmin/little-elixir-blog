## Let's make this thing a real blog
#### First, how would we store content?
I found that markdown is okay for me and Elixir [have plenty of libs for it.](https://github.com/h4cc/awesome-elixir#markdown). However, most of them are NIFs (not native code bindings), so i chose [Earmark](https://github.com/pragdave/earmark).
Let's add it to mix.exs deps method and call `mix deps.get`:
```
 $ git diff mix.exs
@@ -49,7 +49,8 @@ defmodule MySite.MixProject do
       {:plug_cowboy, "~> 2.0"},
-      {:distillery, "~> 2.0"}
+      {:distillery, "~> 2.0"},
+      {:earmark, "1.4.1"}
     ]
   end
```

To store this data we need some database model. Since we using Phoenix framework, de-facto standard in Elixir world for building web-stuff, we'll use Ecto, database wrapper and query executor. It comes out of the box with Phoenix and there are no such many alternatives for beginner.
Let's use it's standard model scaffolding mix task to generate a post model and database migration for it.
If you don't know what migration is: shortly, it's a list of commands, devoted to database structure changing. You can read more about it [here, in official docs](https://hexdocs.pm/ecto_sql/Ecto.Migration.html)
```
$ mix phx.gen.schema Post posts markdown:text header:text
* creating lib/my_site/post.ex  
* creating priv/repo/migrations/20191008154332_create_posts.exs
```
Erlang/Elixir VM doesn't give a shit about code file locations and scaffolding task placed model file to lib/my_site/ folder, but I prefered to make new directory `lib/my_site/models/` and move file to this dir to track models more easily. It's just for humans convenience.
After it, let's run migrations and create posts table.
```
$ mix ecto.migrate
22:58:26.630 [info]  == Running 20191008154332 MySite.Repo.Migrations.CreatePosts.change/0 forward
22:58:26.632 [info]  create table posts
22:58:26.673 [info]  == Migrated 20191008154332 in 0.0s

```

Tonight I'm not in a mood of building whole CRUD shitload of stuff, but lets render posts on a index page:

```
$ git diff --staged lib/my_site_web/controllers/page_controller.ex
@@ -1,7 +1,11 @@
 defmodule MySiteWeb.PageController do
   use MySiteWeb, :controller
+  alias MySite.Repo
+  alias MySite.Post
+  import Ecto.Query, only: [from: 2]

   def index(conn, _params) do
-    render(conn, "index.html")
+    blog_posts = Repo.all(from p in Post, [order_by: :inserted_at])
+    render(conn, "index.html", blog_posts: blog_posts)
   end
 end
```

What we do here is simple:
*  alias MySite.Repo(default Ecto Repo of this Phoenix application) and MySite.Post(it's a model module) to call them in more convenient way.
* import Ecto.Query.from/2 function to make ecto queries.
* Get blog_posts from database using `Repo.all(from p in Post, [order_by: :inserted_at])`, which is pretty self-explanatory.
* Passing blog_posts variable to render function as optional keyword list argument


####  Rendering this stuff
Since we want to render blog posts on this site, we want to get html from markdown. Let's add method as_html/1 to MySite.Post.
```
$ git diff lib/my_site/models/post.ex
--- /dev/null
+++ b/lib/my_site/models/post.ex
@@ -0,0 +1,27 @@
+defmodule MySite.Post do
+ [...some automatically generated code here ]
+
+  def as_html(%MySite.Post{markdown: markdown}) do
+    result = Earmark.as_html(markdown)
+
+    case result do
+      {:ok, html, _} -> html
+      {:error, _, _} -> ""
+    end
+  end
+end
```
Earmark library goes with widely-spread Elixir convention to return either `{:ok, result, _something}` tuple, or with `{:error, original_args, errors_list}`. Using Elixir's pattern matching we safely return html if result is :ok and empty string if is not.

After it, we can tweak our template:
```
 git diff --staged lib/my_site_web/templates/page/index.html.eex
diff --git a/lib/my_site_web/templates/page/index.html.eex b/lib/my_site_web/templates/page/index.html.eex
index 10152b8..28db092 100644
--- a/lib/my_site_web/templates/page/index.html.eex
+++ b/lib/my_site_web/templates/page/index.html.eex
@@ -21,8 +21,24 @@
+<%= for blog_post <- @blog_posts do %>
+  <div class="blog-post">
+    <div class="page-header">
+      <h1>
+        <%= blog_post.header%>
+      </h1>
+    </div>
+    <br>
+    <div class="post-body">
+      <%= blog_post |> MySite.Post.as_html |> Phoenix.HTML.raw %>
+    </div>
+  </div>
+<% end %>
+ [...some minor changes]
```

This changes are easy to understand too. Remember passed `blog_posts: blog_posts` optional keyword list? Thanks to Phoenix under-the-hood metaprogramming, now we can access each member of this list using `@key_name` call, like with `@blog_posts` in template.
To iterate list of posts we are using `for n <- list` syntax and then we just call proper methods and html tags.

Since i'm too lazy to write whole CRUD for today(i have this text to write first), we need to creare first post to check it.
```
# we have some blog post in file
echo "#First blog post" > first_blog_post.md

# lets start interactive shell
$ iex -S mix
Erlang/OTP 22 [erts-10.4.4] [source] [64-bit] [smp:8:8] [ds:8:8:10] [async-threads:1]

# read file using same pattern matching strategy as in Post#as_html
{:ok, markdown} = File.read 'first_post.md'
=> {:ok, "#First blog post"}

# get an Ecto changeset, special object for inserting/updating/validating db records
changeset = MySite.Post.changeset(%MySite.Post{}, %{markdown: markdown, header: "Fist real post in this blog"})
=> #Ecto.Changeset<
  action: nil,
  changes: %{
    header: "Fist real post in this blog",
    markdown: "#First blog post"
  },
  errors: [],
  data: #MySite.Post<>,
  valid?: true
>

# insert new record
MySite.Repo.insert(changeset)
=> {:ok, %MySite.Post{[...lots of omitted info here]}
```

It's time to refresh page!

You can find complete git diff on [github commit page](https://github.com/maximkuzmin/little-elixir-blog/commit/b22ffaf76000121ed42ba8ed3457cc898bd10116)
