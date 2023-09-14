<script context="module" lang="ts">
  export const attr_map = {
    Hide: {
      desc: 'Ẩn nghĩa của từ khi dịch',
      used: true,
    },
    Asis: {
      desc: 'Không viết hoa cụm từ',
      used: true,
    },

    At_h: {
      desc: 'Đặt tại phía trước',
      used: true,
    },
    At_t: {
      desc: 'Đặt tại phía sau',
      used: true,
    },

    Prfx: {
      desc: 'Đánh dấu tiền tố',
      used: true,
    },
    Sufx: {
      desc: 'Đánh dấu hậu tố',
      used: true,
    },

    Capn: {
      desc: 'Viết hoa từ tiếp theo',
      used: true,
    },
    Capx: {
      desc: 'Chuyển viết hoa ra sau',
      used: true,
    },

    Undb: {
      desc: 'Không thêm dấu cách phía trước',
      used: true,
    },
    Undn: {
      desc: 'Không thêm dấu cách phía sau',
      used: true,
    },
    Ndes: {
      desc: 'Danh từ chỉ tính chất sự vật sự việc',
      used: true,
    },
    Npos: {
      desc: 'Danh từ chỉ đối tượng sở hữu cụ thể',
      used: true,
    },
    Nper: {
      desc: 'Danh/đại từ chỉ người',
      used: true,
    },
    Ngrp: {
      desc: 'Danh/đại từ chỉ nhóm',
      used: false,
    },
    Nloc: {
      desc: 'Danh/đại từ chỉ nơi chốn',
      used: true,
    },
    Ntmp: {
      desc: 'Danh/đại từ chỉ thời gian',
      used: true,
    },

    Pn_d: {
      desc: 'Đại từ chỉ thị',
      used: true,
    },

    Pn_i: {
      desc: 'Đại từ nghi vấn',
      used: true,
    },

    Vint: {
      desc: 'Động từ không đối tượng',
      used: false,
    },

    Vdit: {
      desc: 'Động từ hai đối tương',
      used: false,
    },

    Vmod: {
      desc: 'Động từ năng nguyện',
      used: false,
    },

    Vpsy: {
      desc: 'Động từ tâm lý',
      used: false,
    },
  }

  const groups = [
    ['At_h', 'At_t', 'Prfx', 'Sufx'],
    ['Ndes', 'Npos', 'Nper', 'Ngrp', 'Nloc', 'Ntmp', 'Pn_d', 'Pn_i'],
    ['Hide', 'Asis', 'Capn', 'Capx', 'Undb', 'Undn'],
    ['Vint', 'Vdit', 'Vmod', 'Vpsy'],
  ]
</script>

<script lang="ts">
  import { tooltip } from '$lib/actions'

  import SIcon from '$gui/atoms/SIcon.svelte'
  import Dialog from '$gui/molds/Dialog.svelte'

  export let actived = false
  export let output = ''

  // prettier-ignore
  const on_close = (_?: any) => { actived = false }

  const toggle_attr = (attr: string) => {
    if (output.includes(attr)) output = output.replace(attr, '').trim()
    else output = (output + ' ' + attr).trim()
  }

  $: attrs = output.trim().split(' ').filter(Boolean)
</script>

<Dialog --z-idx={80} class="attr-picker" {on_close}>
  <svelte:fragment slot="header">
    <span>Từ tính</span>
  </svelte:fragment>

  <section class="body">
    <h3>Đang có hiệu lực</h3>
    <div class="list">
      {#each attrs as attr}
        {@const { desc, used } = attr_map[attr] || { desc: '??', used: false }}
        <button
          class="attr _active"
          class:_unused={!used}
          use:tooltip={desc}
          data-anchor=".attr-picker"
          on:click={() => toggle_attr(attr)}>
          <span>{attr}</span>
          <SIcon name="check" />
        </button>
      {:else}
        <div class="none">Chưa có từ tính</div>
      {/each}
    </div>

    <h3 id="attr-group">Tất cả từ tính</h3>
    {#each groups as list}
      <div class="list">
        {#each list as attr}
          {@const active = attrs.includes(attr)}
          {@const { desc, used } = attr_map[attr] || {}}
          <button
            class="attr"
            class:_active={active}
            class:_unused={!used}
            data-tag={attr}
            use:tooltip={desc || '???'}
            data-anchor=".attr-picker"
            on:click={() => toggle_attr(attr)}>
            <span>{attr}</span>
            {#if active}<SIcon name="check" />{/if}
          </button>
        {/each}
      </div>
    {/each}
  </section>

  <footer class="foot">
    <p><code>∗</code>: Những từ tính chưa có tác dụng!</p>
  </footer>
</Dialog>

<style lang="scss">
  $tab-height: 1.875rem;

  h3 {
    font-weight: 500;
    line-height: 2.25rem;
    margin: 0rem 0.75rem;
    font-size: rem(15px);
    @include fgcolor(tert);
  }

  .body {
    display: block;
    position: relative;
    // padding-top: 0.25rem;
    padding-bottom: 0.75rem;
    height: 22rem;
    max-height: calc(100vh - 6.5rem);
    @include scroll();
    @include bgcolor(secd);
  }

  .list {
    @include grid(null, $gap: 0.375rem);
    grid-template-columns: 1fr 1fr 1fr 1fr;
    padding: 0 0.75rem;

    & + & {
      margin-top: 0.375rem;
      padding-top: 0.375rem;
      @include border($loc: top);
    }
  }

  .none {
    line-height: 1.75rem;
    font-style: italic;
    @include fgcolor(tert);
    @include ftsize(sm);
  }

  .attr {
    padding: 0;
    background: transparent;
    font-weight: 500;

    flex-shrink: 1;
    line-height: 1.75rem;

    @include linesd(--bd-main);

    @include fgcolor(tert);
    @include bdradi(0.75rem);
    @include bps(font-size, rem(13px), $pl: rem(14px));
    @include clamp($width: 100%);

    &:hover,
    &._active {
      @include fgcolor(primary, 7);
      @include bgcolor(primary, 1);
      @include linesd(primary, 2, $ndef: false);

      @include tm-dark {
        @include fgcolor(primary, 3);
        @include bgcolor(primary, 9, 5);
        @include linesd(primary, 8, $ndef: false);
      }
    }

    &._unused {
      @include fgcolor(mute);
      font-style: italic;
      &:after {
        // font-size: rem(10px);
        content: '∗';
      }
    }
  }

  .foot {
    @include flex-ca;
    @include fgcolor(tert);
    font-style: italic;
    @include ftsize(sm);
  }
</style>
