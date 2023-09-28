<script context="module" lang="ts">
  export type Tab = {
    type: string
    href: string
    icon: string
    text: string
    desc?: string
    mute?: boolean
  }
</script>

<script lang="ts">
  import SIcon from '$gui/atoms/SIcon.svelte'

  export let tabs: Array<Tab>
  export let root: string = ''
  export let _now: string = ''
</script>

<article class="section island">
  <header class="head">
    {#each tabs as { type, href, icon, text, desc, mute }}
      <a
        href="{root}{href}"
        class="htab"
        class:mute
        class:_active={type == _now}
        data-tip={desc}>
        <SIcon name={icon} />
        <span>{text}</span>
      </a>
    {/each}
  </header>

  <div class="body"><slot /></div>
</article>

<style lang="scss">
  .section {
    @include bgcolor(tert);
    @include shadow(2);
    @include padding-x(var(--gutter));
    @include padding-y(0);

    @include tm-dark {
      @include linesd(--bd-soft, $ndef: false, $inset: false);
    }
  }

  .head {
    display: flex;
    @include border(--bd-main, $loc: bottom);
  }

  .htab {
    @include flex-ca;
    flex-direction: column;
    padding: 0.5rem 0 0.25rem;

    font-weight: 500;
    flex: 1;

    --color: var(--fg-secd, #555);
    color: var(--color, inherit);

    > :global(svg) {
      width: 1.25rem;
      height: 1.25rem;
      // opacity: 0.8;
    }

    > span {
      @include ftsize(sm);
    }

    @include bp-min(ts) {
      flex-direction: row;
      padding: 0.75rem 0;

      > :global(svg) {
        margin-right: 0.25rem;
      }

      > span {
        @include ftsize(md);
      }
    }

    &._active {
      --color: #{color(primary, 6)};
      position: relative;

      &:after {
        position: absolute;
        bottom: 0;
        left: 0;
        width: 100%;
        content: '';
        @include border(primary, 5, $width: 2px, $loc: bottom);
      }

      @include tm-dark {
        --color: #{color(primary, 4)};
      }
    }

    &.mute {
      --color: var(--fg-mute);
    }
  }

  // .body {
  //   padding: 0.75rem 0;
  //   display: block;
  //   min-height: 50vh;
  // }
</style>
