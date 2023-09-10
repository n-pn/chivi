<script context="module" lang="ts">
  export interface Crumb {
    text: string
    href?: string
    icon?: string
  }
</script>

<script lang="ts">
  import SIcon from '$gui/atoms/SIcon.svelte'

  export let items: Crumb[]
</script>

<nav class="bread">
  <span class="crumb"><a href="/"><SIcon name="home" />Trang chủ</a></span>
  {#each items as { text, href, icon }}
    <div class="crumb">
      <svelte:element this={href ? 'a' : 'span'} {href}>
        {#if icon}<SIcon name={icon} />{/if}{text}
      </svelte:element>
    </div>
  {/each}

  <slot />
</nav>

<style lang="scss">
  .bread {
    padding: 0.75rem 0;
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

    > span,
    > a {
      @include fgcolor(tert);
    }

    > a {
      @include hover {
        @include fgcolor(primary, 5);
      }
    }

    :global(svg) {
      height: 1rem;
      width: 1rem;
      @include fgcolor(mute);
      vertical-align: text-top;
      padding-right: 0.25rem;
    }
  }
</style>
