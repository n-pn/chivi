<script context="module" lang="ts">
  export const attr_map = {
    Hide: {
      desc: 'Ẩn cả cụm từ (không thêm nghĩa) của từ khi dịch',
      used: true,
    },
    Asis: {
      desc: 'Giữ nguyên cụm từ, không áp dụng viết hoa',
      used: true,
    },

    At_h: {
      desc: 'Trong trường hợp đặc biệt, đặt từ ở phía đầu của cụm (!)',
      used: true,
    },
    At_t: {
      desc: 'Trong trường hợp đặc biệt, đặt từ ở phía cuối của cụm (!)',
      used: true,
    },

    Prfx: {
      desc: 'Đánh dấu từ là tiền tố của một cụm từ (ít dùng)',
      used: true,
    },
    Sufx: {
      desc: 'Đánh dấu từ là hậu tố cho danh từ, động từ, tính từ, tên riêng etc.',
      used: true,
    },

    Capn: {
      desc: 'Viết hoa cụm từ ngay tiếp theo từ này (áp dụng cho dấu câu)',
      used: true,
    },
    Capx: {
      desc: 'Chuyển tiếp yêu cầu viết hoa cho cụm từ phía sau',
      used: true,
    },

    Undb: {
      desc: 'Không thêm dấu cách phía trước (áp dụng cho dấu câu)',
      used: true,
    },
    Undn: {
      desc: 'Không thêm dấu cách phía sau (áp dụng cho dấu câu)',
      used: true,
    },
    Ndes: {
      desc: 'Danh từ chỉ tính chất sự vật sự việc, khi làm định ngữ không có `của`',
      used: true,
    },
    Npos: {
      desc: 'Danh từ chỉ đối tượng sở hữu cụ thể, khi làm định ngữ sẽ thêm `của`',
      used: true,
    },
    Nper: {
      desc: 'Các danh/đại từ chỉ người, gồm cả tên riêng, danh xưng, chức vụ',
      used: true,
    },
    Ngrp: {
      desc: 'Danh/đại từ chỉ nhóm người, tổ chức, dân tộc, số nhiều',
      used: false,
    },
    Nloc: {
      desc: 'Danh/đại từ chỉ nơi chốn địa điểm, kể cả địa danh, tổ chức',
      used: true,
    },
    Ntmp: {
      desc: 'Danh/đại từ chỉ thời gian, ngày tháng, khoảng thời gian',
      used: true,
    },

    Pn_d: {
      desc: 'Đại từ chỉ thị (từ loại con của đại từ)',
      used: true,
    },

    Pn_i: {
      desc: 'Đại từ nghi vấn (từ loại con của đại từ)',
      used: true,
    },

    Vint: {
      desc: 'Động từ không đối tượng (từ loại con của động từ)',
      used: false,
    },

    Vdit: {
      desc: 'Động từ hai đối tượng (từ loại con của động từ)',
      used: false,
    },

    Vmod: {
      desc: 'Động từ năng nguyện (từ loại con của động từ)',
      used: false,
    },

    Vpsy: {
      desc: 'Động từ tâm lý (từ loại con của động từ)',
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
    {#each groups as list}
      <div class="list">
        {#each list as attr}
          {@const active = attrs.includes(attr)}
          {@const { desc, used } = attr_map[attr] || {}}

          <button
            class="attr"
            class:_active={active}
            class:_unused={!used}
            on:click={() => toggle_attr(attr)}>
            <SIcon name={active ? 'check' : 'square'} />
            <code>{attr}</code>
            <span>{desc}</span>
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
    // @include grid(null, $gap: 0.375rem);
    // grid-template-columns: 1fr 1fr 1fr 1fr;
    margin-top: 0.375rem;
    padding: 0 0.75rem;

    & + & {
      padding-top: 0.375rem;
      @include border($loc: top);
    }
  }

  .attr {
    padding: 0;
    background: transparent;

    line-height: 1.75rem;
    text-align: left;

    border: none;
    @include fgcolor(tert);
    @include bps(font-size, rem(13px), $pl: rem(14px));
    @include clamp($width: 100%);

    &:hover,
    &._active {
      @include fgcolor(primary, 7);

      @include tm-dark {
        @include fgcolor(primary, 3);
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
