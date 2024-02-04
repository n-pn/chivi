<script lang="ts">
  import { page } from '$app/stores'
  import SIcon from '$gui/atoms/SIcon.svelte'

  $: navs = $page.data._navs || []
</script>

{#if navs.length}
  <nav class="app-vessel">
    <div class="bread">
      <a href="/" class="crumb"><SIcon name="home" />Trang chủ</a>
      {#each navs as { text, href = '.' }}
        <span class="crumb _sep">/</span><a {href} class="crumb">{text}</a>
      {/each}
    </div>
  </nav>
{/if}

<style lang="scss">
  .bread {
    margin-top: 0.75rem;
    margin-bottom: 0.75rem;
    line-height: 1.25rem;
    @include ftsize(sm);
  }

  a {
    @include fgcolor(tert);
    @include hover {
      @include fgcolor(primary, 5);
    }

    :global(svg) {
      vertical-align: text-top;
      // padding-right: 0.125rem;
      @include fgcolor(mute);
    }
  }

  ._sep {
    margin-left: 0.5ch;
    margin-right: 0.5ch;
    font-size: 0.85em;
    @include fgcolor(mute);
  }
</style>
