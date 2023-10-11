<script lang="ts">
  import { page } from '$app/stores'

  import { get_user } from '$lib/stores'
  const _user = get_user()

  import SIcon from '$gui/atoms/SIcon.svelte'
  import Section from '$gui/sects/Section.svelte'

  import RmstemFull from '$gui/parts/rmstem/RmstemFull.svelte'

  import type { LayoutData } from './$types'
  export let data: LayoutData

  $: ({ rstem, sroot } = data)

  // prettier-ignore
  $: tabs = {
    rd: [
      { type: 'ch', href: `${sroot}`, icon: 'list', text: 'Mục lục' },
      // { type: 'dl', href: `${sroot}/dl`, icon: 'download', text: 'Tải xuống' },
      { type: 'gd', href: `${sroot}/gd`, icon: 'message', text: 'Thảo luận' },
      // { type: 'st', href: `${sroot}/st`, icon: 'activity', text: 'Thay đổi' },
    ],
    ul: [
      { type: 'zh', href: `${sroot}/ul`, icon: 'upload', text: 'Text gốc' },
      { type: 'tl', href: `${sroot}/ul/tran`, icon: 'language', text: 'Bản dịch' },
      { type: 'md', href: `${sroot}/ul/data`, icon: 'tree', text: 'Ngữ pháp' },
      // { type: 'vd', href: `${sroot}/ul/term`, icon: 'package', text: 'Từ điển' },
    ],
    su: [
      { type: 'cf', href: `${sroot}/su`, icon: 'settings', text: 'Thiết đặt' },
      { type: 'rm', href: `${sroot}/su/redo`, icon: 'eraser', text: 'Tẩy xóa' },
      { type: 'lg', href: `${sroot}/su/xlog`, icon: 'lock-open', text: 'Mở khóa' },
    ],
  }

  $: ({ intab = 'rd', ontab = 'ch' } = $page.data)
</script>

<RmstemFull {rstem} binfo={data.binfo || null} />

{#if $_user.privi >= 3}
  <nav class="admin">
    <a href="{sroot}/ul" class="m-btn _fill _primary">
      <SIcon name="upload" />
      <span class="-txt">Thêm nội dung</span>
    </a>
    <a href="{sroot}/su" class="m-btn">
      <SIcon name="tools" />
      <span class="-txt">Trang quản lý</span>
    </a>
  </nav>
{/if}

<Section tabs={tabs[intab]} _now={ontab}>
  <slot />
</Section>

<style lang="scss">
  .admin {
    @include flex-ca($gap: 0.5rem);
    margin-bottom: 1rem;
  }
</style>
