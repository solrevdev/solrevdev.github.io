---
published: true
---
Today, I fixed a bug where session cookies were not being persisted in an ASP.Net Core Razor Pages application.

The answer was in the [documentation](https://docs.microsoft.com/en-us/aspnet/core/fundamentals/app-state?view=aspnetcore-3.1#configure-session-state).

To quote that page:

    The order of middleware is important. Call `UseSession` after `UseRouting` and before `UseEndpoints`


So my code which did work in the past, but probably before [endpoint routing] was introduced was this:

```csharp
app.UseSession();
app.UseRouting();
app.UseEndpoints(endpoints =>
{
    endpoints.MapControllers();
    endpoints.MapRazorPages();
});
```

And the fix was to move `UseSession` below `UseRouting`

```csharp
app.UseRouting();
app.UseSession();
app.UseEndpoints(endpoints =>
{
    endpoints.MapControllers();
    endpoints.MapRazorPages();
});
```

Success 🎉
