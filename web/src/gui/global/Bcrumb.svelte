<script lang="ts">
  import { page } from '$app/stores'
  import SIcon from '$gui/atoms/SIcon.svelte'

  $: navs = $page.data._navs || []
</script>

{#if navs.length}
  <nav class="app-vessel bread">
    <span class="crumb"><a href="/"><SIcon name="home" />Trang chủ</a></span>
    {#each navs as { text, href = '.' }}
      <span class="crumb"><a {href}>{text}</a></span>
    {/each}
  </nav>
{/if}

<style lang="scss">
  .bread {
    display: flow-root;
    margin-top: 0.75rem;
    margin-bottom: 0.75rem;

    line-height: 1.25rem;
    @include ftsize(sm);

    // display: flex;
    // flex-wrap: wrap;
  }

  .crumb {
    float: left;
    // display: inline;

    &:not(:last-child):after {
      vertical-align: top;

      margin-left: 0.25rem;
      margin-right: 0.25rem;

      content: '/';
      font-size: 0.775em;

      @include fgcolor(mute);
    }

    a {
      @include fgcolor(tert);
      @include hover {
        @include fgcolor(primary, 5);
      }
    }

    :global(svg) {
      font-size: large;
      @include fgcolor(mute);
      vertical-align: top;
      padding-right: 0.25rem;
    }
  }
</style>
