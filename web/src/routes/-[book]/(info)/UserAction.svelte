<script lang="ts">
  import { last_read } from '$utils/ubmemo_utils'

  import { SIcon, Gmenu } from '$gui'
  import BookTrack from '$gui/parts/BookTrack.svelte'

  export let nvinfo: CV.Nvinfo
  export let ubmemo: CV.Ubmemo

  $: toread = last_read(nvinfo, ubmemo)
</script>

<div class="user-action">
  <a class="m-btn _fill _primary" href="/-{nvinfo.bslug}/chaps">
    <SIcon name="list" />
    <span>Chương tiết</span>
  </a>

  <a class="m-btn" class:_primary={!toread.mute} href={toread.href}>
    <SIcon name={toread.icon} />
    <span class="u-show-md">{toread.text}</span>
  </a>

  <BookTrack {nvinfo} {ubmemo} />

  <Gmenu class="action" loc="bottom" r>
    <button class="m-btn " slot="trigger">
      <SIcon name="dots" />
    </button>

    <svelte:fragment slot="content">
      <a class="gmenu-item" href="/dicts/-{nvinfo.bhash}" data-kbd="p">
        <SIcon name="package" />
        <span>Từ điển truyện</span>
      </a>

      <a class="gmenu-item _harmful" href="/-{nvinfo.bslug}/+info">
        <SIcon name="edit" />
        <span>Sửa thông tin</span>
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
