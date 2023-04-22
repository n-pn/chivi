<script lang="ts">
  import { chap_path } from '$lib/kit_path'

  import { SIcon, Gmenu } from '$gui'
  import MarkBook from './MarkBook.svelte'

  export let nvinfo: CV.Wninfo
  export let ubmemo: CV.Ubmemo

  $: toread = last_read(nvinfo, ubmemo)
  $: root_path = `/wn/${nvinfo.bslug}`

  function last_read({ bslug }, ubmemo: CV.Ubmemo) {
    let { locked, chidx = 1, cpart = 1 } = ubmemo
    if (chidx < 1) chidx = 1

    let sname = ubmemo.sname || '_'

    return {
      href: chap_path(bslug, sname, chidx, cpart),
      icon: locked ? 'player-skip-forward' : 'player-play',
      text: ubmemo.chidx > 0 ? 'Đọc tiếp' : 'Đọc thử',
      mute: ubmemo.chidx < 0,
    }
  }
</script>

<div class="user-action">
  <a class="m-btn _fill _primary" href="{root_path}/chaps">
    <SIcon name="list" />
    <span>Chương tiết</span>
  </a>

  <a class="m-btn" class:_primary={!toread.mute} href={toread.href}>
    <SIcon name={toread.icon} />
    <span class="u-show-md">{toread.text}</span>
  </a>

  <MarkBook {nvinfo} {ubmemo} />

  <Gmenu class="action" loc="bottom" r>
    <button class="m-btn" slot="trigger">
      <SIcon name="dots" />
    </button>

    <svelte:fragment slot="content">
      <a class="gmenu-item _success" href="/uc/+crit?wn={nvinfo.id}">
        <SIcon name="ballpen" />
        <span>Thêm đánh giá</span>
      </a>

      <a class="gmenu-item _harmful" href="/wn/+book?id={nvinfo.id}">
        <SIcon name="edit" />
        <span>Sửa thông tin</span>
      </a>

      <a class="gmenu-item" href="/mt/dicts/{nvinfo.bslug}" data-kbd="p">
        <SIcon name="package" />
        <span>Từ điển truyện</span>
      </a>
    </svelte:fragment>
  </Gmenu>

  <div class="more-action" />
</div>

<style lang="scss">
  .user-action {
    grid-area: d;
    display: flex;
    gap: 0.5rem;
    align-items: center;
    // margin-top: 0.5rem;

    // @include padding-x(var(--gutter));
    justify-content: center;

    @include bp-min(pl) {
      justify-content: left;
    }
  }
</style>
