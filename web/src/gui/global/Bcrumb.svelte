<script lang="ts">
  import { page } from '$app/stores'
  import SIcon from '$gui/atoms/SIcon.svelte'

  $: navs = $page.data._navs || []
</script>

<!-- {#if navs.length} -->
<nav class="bread">
  <span class="crumb"><a href="/"><SIcon name="home" />Trang chủ</a></span>
  {#each navs as { text, href = '.' }}
    <div class="crumb"><a {href}>{text}</a></div>
  {/each}
</nav>

<!-- {/if} -->

<style lang="scss">
  .bread {
    margin: 0.75rem 0;
    line-height: 1.25rem;
    @include ftsize(sm);
    display: flex;
    flex-wrap: wrap;
  }

  .crumb {
    display: inline;

    &:not(:last-child):after {
      display: inline-flex;
      vertical-align: top;

      margin-left: 0.25rem;
      margin-right: 0.25rem;

      content: '/';
      font-size: 0.775em;

      @include fgcolor(mute);
    }

    > * {
      @include fgcolor(tert);
      @include hover {
        @include fgcolor(primary, 5);
      }
    }

    :global(svg) {
      font-size: large;
      @include fgcolor(mute);
      vertical-align: text-top;
      padding-right: 0.25rem;
    }
  }
</style>
