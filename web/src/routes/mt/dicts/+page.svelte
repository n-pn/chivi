<script lang="ts">
  import { page } from '$app/stores'
  import { Footer, Mpager } from '$gui'
  import { Pager } from '$gui/molds/Mpager.svelte'

  import type { PageData } from './$types'
  export let data: PageData

  import Section from '$gui/sects/Section.svelte'
  import { rel_time_vp } from '$utils/time_utils'

  const tabs = [
    { type: 'cv', href: `/mt/dicts`, icon: 'world', text: 'Dùng chung' },
    {
      type: 'wn',
      href: `/mt/dicts?kind=wn`,
      icon: 'books',
      text: 'Truyện chữ',
    },
    { type: 'up', href: `/mt/dicts?kind=up`, icon: 'folder', text: 'Sưu tầm' },
  ]
</script>

<Section {tabs} _now={data.ontab}>
  <h2>Danh sách từ điển <em>({data.total})</em></h2>

  <div class="dicts">
    {#each data.dicts as { name, label, brief, mtime, total }}
      <a class="-dict" href="/mt/dicts/{name}">
        <div class="-name">{label}</div>
        <div class="-desc">{brief}</div>
        <div class="-meta">
          <div class="-size">
            <em>Số từ:</em>
            <strong>{total}</strong>
          </div>
          <div class="-time">
            <em>Cập nhật: </em>
            <strong>{rel_time_vp(mtime)}</strong>
          </div>
        </div>
      </a>
    {/each}
  </div>

  <Footer>
    <Mpager pager={new Pager($page.url)} pgidx={data.pgidx} pgmax={data.pgmax} />
  </Footer>
</Section>

<style lang="scss">
  .dicts {
    @include grid(minmax(12.5rem, 1fr), $gap: var(--gutter-pl));
  }

  h2 {
    margin: 1rem 0;
  }

  .-dict {
    padding: 0.5rem;
    position: relative;
    // height: 5rem;

    @include bdradi();
    @include shadow(1);

    @include bgcolor(secd);

    &:hover {
      @include bgcolor(main);
      & > .-name {
        @include fgcolor(primary, 5);
      }
    }
  }

  .-name {
    font-weight: 500;
    // text-transform: capitalize;
    line-height: 1.5rem;
    @include clamp($width: null);
    @include fgcolor(secd);
  }

  .-desc {
    @include clamp(2);
    @include ftsize(sm);
    line-height: 1.25rem;
    font-style: italic;
    @include fgcolor(tert);
    margin: 0.25rem 0;
  }

  .-meta {
    // margin-top: 0.25rem;
    display: flex;
    font-size: rem(14px);
    // font-style: italic;
    @include fgcolor(mute);

    strong {
      @include fgcolor(tert);
    }
  }

  .-time {
    margin-left: auto;
  }
</style>
