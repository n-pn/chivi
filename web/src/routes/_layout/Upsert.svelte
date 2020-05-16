<script context="module">
  export function suggest_urls(key) {
    return [
      { site: 'iCIBA', href: `https://www.iciba.com/${key}` },
      {
        site: 'Google Translation',
        href: `https://translate.google.com/#view=home&op=translate&sl=zh-CN&tl=vi&text=${key}`,
      },
      {
        site: 'Google',
        href: `https://www.google.com/search?q=${key}`,
      },
      {
        site: 'Baidu Fanyi',
        href: `https://fanyi.baidu.com/#zh/en/${key}`,
      },
      {
        site: 'Baike',
        href: `https://baike.baidu.com/item/${key}`,
      },
    ]
  }
</script>

<script>
  import { onMount, afterUpdate } from 'svelte'

  const tabs = [['special', 'Riêng'], ['generic', 'Chung']]

  export let active = true

  export let key = ''
  export let dic = 'combine'
  export let tab = 'special'

  let key_field
  let val_field

  let val = ''

  $: active_dic = tab == 'special' ? dic : 'generic'
  $: if (key) inquire()

  $: links = suggest_urls(key)

  let props = {
    hanviet: '',
    pinyins: '',
    generic: { vals: [], time: null },
    special: { vals: [], time: null },
    suggest: [],
  }

  onMount(() => {
    if (key == '') key_field.focus()
    else val_field.focus()
  })

  function change_tab(new_tab) {
    tab = new_tab
    update_val()
    val_field.focus()
  }

  function update_val() {
    val = props[tab].vals[0] || props.suggest[0] || props.hanviet
    if (tab === 'special') upcase_val()
  }

  async function upsert() {
    const url = `/api/upsert?dic=${active_dic}&key=${key}&val=${val}`
    const res = await fetch(url)
    active = false
  }

  async function remove() {
    const res = await fetch(`/api/upsert?dic=${active_dic}&key=${key}`)
    active = false
  }

  async function inquire() {
    links = suggest_urls(key)

    const res = await fetch(`/api/inquire?key=${key}`)
    props = await res.json()
    update_val()
  }

  function capitalize(input) {
    return input.charAt(0).toUpperCase() + input.slice(1)
  }

  function upcase_val(count = 100) {
    const arr = val.split(' ')
    if (count > arr.length) count = arr.length

    for (let i = 0; i < count; i++) arr[i] = capitalize(arr[i])
    for (let i = count; i < arr.length; i++) arr[i] = arr[i].toLowerCase()

    val = arr.join(' ')
    val_field.focus()
  }

  function submitOnEnter(evt) {
    if (evt.keyCode == 13 && !evt.shiftKey) {
      evt.preventDefault()
      return upsert()
    }
  }
</script>

<div class="container" on:click={() => (active = false)}>
  <div class="dialog" on:click={evt => evt.stopPropagation()}>
    <header>
      <span class="label">Thêm từ:</span>
      {#each tabs as [name, label]}
        <span
          class="tab"
          class:_active={name == tab}
          on:click={() => change_tab(name)}>
          {label}
        </span>
      {/each}

      <button
        type="button"
        class="m-button _text"
        on:click={() => (active = false)}>
        <svg class="m-icon _x">
          <use xlink:href="/icons.svg#x" />
        </svg>
      </button>
    </header>

    <section class="key">
      <input
        class="key-inp"
        type="text"
        name="key"
        bind:value={key}
        bind:this={key_field} />

      <div class="key-lit">
        {#if key}
          <span class="hanviet">{props.hanviet}</span>
          <span class="pinyins">[{props.pinyins}]</span>
        {/if}
      </div>
    </section>

    <section class="val">
      <div class="cap">
        <span class="cap-lbl">Viết hoa:</span>
        <span class="cap-btn" on:click={() => upcase_val(0)}>không</span>
        <span class="cap-btn" on:click={() => upcase_val(1)}>1 chữ</span>
        <span class="cap-btn" on:click={() => upcase_val(2)}>2 chữ</span>
        <span class="cap-btn" on:click={() => upcase_val(3)}>3 chữ</span>
        <span class="cap-btn" on:click={() => upcase_val(99)}>toàn bộ</span>
      </div>

      <textarea
        lang="vi"
        class="val-inp"
        name="value"
        id="val_field"
        rows="2"
        on:keypress={submitOnEnter}
        bind:this={val_field}
        bind:value={val} />

      <div class="val-act">
        <div class="left" />

        <div class="right">
          <button
            type="button"
            class="m-button _line _harmful"
            on:click={remove}>
            <span>Xoá từ</span>
          </button>
          <button type="button" class="m-button _primary" on:click={upsert}>
            <span>{props[tab].value ? 'Cập nhật' : 'Thêm từ'}</span>
          </button>

        </div>
      </div>

    </section>

    <footer>
      <span>Tra từ:</span>
      {#each links as { site, href }}
        <a {href} target="_blank" rel="noopener noreferer">{site}</a>
      {/each}
    </footer>
  </div>
</div>

<style lang="scss">
  $gutter: 1rem;

  .container {
    position: fixed;
    display: flex;
    align-items: center;
    justify-content: center;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    z-index: 999;
    @include bgcolor(rgba(#000, 0.6));
  }

  .dialog {
    width: rem(29);
    max-width: 100%;
    margin-top: -10%;
    @include bgcolor(white);
    @include radius();
    @include shadow(3);
  }

  $header-height: 3rem;
  $header-gutter: 0.5rem;

  header {
    position: relative;
    padding: $header-gutter $gutter;
    height: $header-height;
    line-height: $header-height - $header-gutter * 2;
    @include bgcolor(color(neutral, 1));
    @include radius($pos: top);
    @include border($pos: bottom);

    .label {
      font-weight: 500;
    }

    .m-button {
      position: absolute;
      right: $header-gutter;
      top: 0.375rem;
      @include hover {
        color: color(primary, 5);
      }
    }
  }

  .tab {
    display: inline-block;
    cursor: pointer;
    text-transform: uppercase;
    margin-left: $header-gutter;
    font-weight: 500;
    padding: 0 0.75rem;
    height: $header-height - $header-gutter * 2;

    @include font-size(2);
    @include fgcolor(color(neutral, 6));

    @include radius();

    @include border();

    &._active {
      @include bgcolor(#fff);
      @include fgcolor(color(primary, 6));
      @include border-color($value: color(primary, 4));
    }
  }

  $label-width: 3rem;

  .key {
    margin: 0 $gutter;
    padding: $gutter 0;
    border-bottom: 1px solid color(neutral, 2);
  }

  .key-inp {
    display: block;
    width: 100%;

    padding: 0 0.75rem;
    line-height: 2.5rem;

    @include radius();

    @include bgcolor(color(neutral, 1));
    @include border($color: color(neutral, 2));

    &:focus {
      @include bgcolor(white);
      @include border-color($value: color(primary, 3));
    }
    // line-height: 1rem;
  }

  .key-lit {
    margin-top: 0.375rem;
    @include font-size(2);
    line-height: 1;
    @include fgcolor(color(neutral, 6));
  }

  .val {
    padding: 0 $gutter;
  }

  .val-inp {
    display: block;
    width: 100%;
    min-height: 2.5rem;
    margin: 0;
    padding: 0.375rem 0.75rem;

    @include radius();
    @include border($color: color(neutral, 2));
    @include bgcolor(color(neutral, 1));
    &:focus,
    &:active {
      @include bgcolor(white);
      @include border-color($value: color(primary, 3));
    }
  }

  .val-act {
    // margin: 1rem 0;
    margin: 0.5rem 0;
    @include flex();
    .left {
      margin-right: auto;
      @include flex($gap: 0.5rem);
    }
    .right {
      margin-left: auto;
      @include flex($gap: 0.5rem);
    }
  }

  .cap {
    display: flex;
    line-height: 1.75rem;
    margin: 0.5rem 0;
  }

  .cap-lbl {
    padding: 0;
    padding-right: 0.375rem;
    max-width: 15vw;
    @include truncate(null);

    @include font-size(2);
    @include fgcolor(color(neutral, 5));
  }

  .cap-btn {
    padding: 0 0.375rem;
    max-width: 20vw;
    cursor: pointer;
    @include truncate(null);
    // text-transform: uppercase;
    @include font-size(2);
    // font-weight: 500;
    @include fgcolor(color(neutral, 6));
    // @include border($color: color(neutral, 3));
    @include radius();
    @include hover {
      @include bgcolor(color(primary, 1));
      @include fgcolor(color(primary, 6));
    }
  }

  footer {
    display: flex;
    @include bgcolor(color(neutral, 1));
    @include radius($pos: bottom);
    // width: 5rem;
    margin: 0;
    padding: 0 0.5rem;
    border-top: 1px solid color(neutral, 2);
    text-align: center;

    span,
    a {
      // display: inline-block;
      line-height: 1rem;
      padding: 0.5rem;
      @include font-size(2);
      // @include font-family(narrow);
    }

    a {
      @include fgcolor(color(neutral, 7));
      display: inline-block;
      border-left: 1px splid color(neutral, 3);

      @include hover {
        cursor: pointer;
        background-color: color(neutral, 3);
      }
    }
  }
</style>
